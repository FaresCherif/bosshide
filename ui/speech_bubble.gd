@tool
class_name SpeechBubble
extends Control

# Bulle de BD : dialogue (rectangle arrondi et pointe) ou reflexion (nuage et petits
# ronds). La pointe descend sous la bulle vers le personnage (affichage seulement).

enum Side { LEFT, RIGHT }

const TAIL_MARGIN := 24.0
const TAIL_HEIGHT := 24.0
# Distance entre la pointe et le bord de la bulle du cote oppose a celui demande
const TAIL_INSET := 44.0
const SCREEN_MARGIN := 8.0
const GAP := 16.0
const FILL := Color(1, 1, 1, 1)
const INK := Color(0.17, 0.17, 0.2, 1)

@export var thought := false:
	set(value):
		thought = value
		queue_redraw()
# Faux quand une ThoughtTrail commune relie plusieurs nuages a la tete
@export var show_dots := true:
	set(value):
		show_dots = value
		queue_redraw()
@export var tail_x := 40.0:
	set(value):
		tail_x = value
		queue_redraw()
# Point local vers lequel vont les petits ronds d'une reflexion (la tete du personnage).
# Vector2.ZERO : ils descendent simplement sous la bulle.
@export var tail_target := Vector2.ZERO:
	set(value):
		tail_target = value
		queue_redraw()


# Rectangle de la bulle au-dessus du point d'ancrage (la tete du personnage, a l'ecran),
# qui part du cote demande, puis recale pour rester entier a l'ecran
# side vaut Side.LEFT ou Side.RIGHT (type int : Godot 4.3 refuse l'enum type venant d'un autre script)
static func place(anchor: Vector2, bubble_size: Vector2, screen_size: Vector2, side: int) -> Rect2:
	var x := anchor.x - TAIL_INSET if side == Side.RIGHT else anchor.x - bubble_size.x + TAIL_INSET
	var y := anchor.y - TAIL_HEIGHT - bubble_size.y
	x = clampf(x, SCREEN_MARGIN, screen_size.x - bubble_size.x - SCREEN_MARGIN)
	y = clampf(y, SCREEN_MARGIN, screen_size.y - bubble_size.y - SCREEN_MARGIN)
	return Rect2(Vector2(x, y), bubble_size)


# Range rect a gauche d'other s'ils se chevauchent ; sans place a gauche, au-dessus d'other
static func avoid(rect: Rect2, other: Rect2, screen_size: Vector2) -> Rect2:
	if not rect.intersects(other):
		return rect
	var left := Rect2(Vector2(other.position.x - GAP - rect.size.x, rect.position.y), rect.size)
	if left.position.x >= SCREEN_MARGIN:
		return left
	var above := Rect2(Vector2(rect.position.x, other.position.y - GAP - rect.size.y), rect.size)
	above.position.y = maxf(above.position.y, SCREEN_MARGIN)
	above.position.x = clampf(above.position.x, SCREEN_MARGIN, screen_size.x - rect.size.x - SCREEN_MARGIN)
	return above


# Position de la pointe dans la bulle, sans toucher les coins arrondis
static func tail_offset(anchor: Vector2, rect: Rect2) -> float:
	return clampf(anchor.x - rect.position.x, TAIL_MARGIN, rect.size.x - TAIL_MARGIN)


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	if thought:
		_draw_thought()
	else:
		_draw_speech()


func _draw_speech() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = FILL
	style.border_color = INK
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(4, 5)
	draw_style_box(style, Rect2(Vector2.ZERO, size))
	var base := size.y - 2.0
	var tail := PackedVector2Array([
		Vector2(tail_x - 12, base), Vector2(tail_x + 12, base), Vector2(tail_x - 4, size.y + TAIL_HEIGHT - 4),
	])
	draw_colored_polygon(tail, FILL)
	draw_polyline(PackedVector2Array([tail[0] + Vector2(0, 2), tail[2], tail[1] + Vector2(0, 2)]), INK, 3.0)


# Nuage : une rangee de bosses sur chaque bord autour d'un coeur blanc
func _draw_thought() -> void:
	var bumps := _cloud_bumps()
	# Contour sombre d'abord, puis le blanc par-dessus
	for pass_index in 2:
		var color := INK if pass_index == 0 else FILL
		var grow := 3.0 if pass_index == 0 else 0.0
		for bump in bumps:
			draw_circle(Vector2(bump.x, bump.y), bump.z + grow, color)
		draw_rect(Rect2(Vector2(18, 18), size - Vector2(36, 36)).grow(grow), color)
	if not show_dots:
		return
	var start := Vector2(tail_x, size.y)
	var target := tail_target if tail_target != Vector2.ZERO else start + Vector2(24, 30)
	for i in 2:
		# Les ronds vont de la bulle vers la tete du personnage
		var dot := start.lerp(target, 0.3 + 0.35 * i)
		draw_circle(dot, 8.0 - 3.0 * i + 2.0, INK)
		draw_circle(dot, 8.0 - 3.0 * i, FILL)


func _cloud_bumps() -> Array[Vector3]:
	var bumps: Array[Vector3] = []
	var radius := minf(32.0, minf(size.x, size.y) / 2.6)
	var step := radius * 1.6
	var x := radius
	while x <= size.x - radius + 0.1:
		bumps.append(Vector3(x, radius, radius))
		bumps.append(Vector3(x, size.y - radius, radius))
		x += step
	var y := radius
	while y <= size.y - radius + 0.1:
		bumps.append(Vector3(radius, y, radius))
		bumps.append(Vector3(size.x - radius, y, radius))
		y += step
	# Un cercle a chaque coin, pour que le pas ne laisse pas de coin carre
	for corner in [Vector2(radius, radius), Vector2(size.x - radius, radius),
			Vector2(radius, size.y - radius), Vector2(size.x - radius, size.y - radius)]:
		bumps.append(Vector3(corner.x, corner.y, radius))
	return bumps
