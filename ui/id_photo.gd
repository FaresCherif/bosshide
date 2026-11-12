@tool
class_name IdPhoto
extends Control

# Photo d'identite facon camera de surveillance : fond vert sombre, icone de
# l'employe (silhouette ou objet de bureau) et lignes de balayage (affichage seulement)

const ICON_IDS := ["classic", "tie", "glasses", "bun", "cap", "shades", "mug", "plant", "stapler", "paper"]
const PEOPLE := ["classic", "tie", "glasses", "bun", "cap", "shades"]

@export var icon_id := "classic":
	set(value):
		icon_id = value if supports(value) else "classic"
		queue_redraw()
@export var background := Color(0.08, 0.16, 0.1, 1)
@export var silhouette := Color(0.45, 0.75, 0.5, 1)
@export var scanline_color := Color(0, 0, 0, 0.25)
@export var scanline_spacing := 4.0


static func supports(id: String) -> bool:
	return ICON_IDS.has(id)


func _ready() -> void:
	resized.connect(queue_redraw)


func head_radius() -> float:
	return minf(size.x, size.y) * 0.2


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), background)
	if PEOPLE.has(icon_id):
		_draw_person()
	else:
		_draw_object()
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), scanline_color, 1.0)
		y += scanline_spacing
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6), false, 2.0)


func _dark() -> Color:
	return silhouette.darkened(0.65)


func _draw_person() -> void:
	var r := head_radius()
	var cx := size.x / 2.0
	var head := Vector2(cx, size.y * 0.4)
	draw_circle(Vector2(cx, size.y + r * 0.6), r * 2.1, silhouette.darkened(0.15))
	if icon_id == "bun":
		draw_circle(head - Vector2(0, r * 1.05), r * 0.45, silhouette)
	draw_circle(head, r, silhouette)
	match icon_id:
		"tie":
			var top := head.y + r * 1.35
			draw_colored_polygon(PackedVector2Array([
				Vector2(cx, top), Vector2(cx + r * 0.28, top + r * 0.45),
				Vector2(cx, size.y), Vector2(cx - r * 0.28, top + r * 0.45),
			]), _dark())
		"glasses":
			for side in [-1.0, 1.0]:
				draw_arc(head + Vector2(side * r * 0.42, 0), r * 0.3, 0.0, TAU, 20, _dark(), 2.5)
			draw_line(head - Vector2(r * 0.12, 0), head + Vector2(r * 0.12, 0), _dark(), 2.0)
		"cap":
			draw_rect(Rect2(cx - r * 1.05, head.y - r * 1.05, r * 2.1, r * 0.6), _dark())
			draw_rect(Rect2(cx, head.y - r * 0.55, r * 1.45, r * 0.2), _dark())
		"shades":
			draw_rect(Rect2(cx - r * 0.85, head.y - r * 0.25, r * 1.7, r * 0.4), Color(0, 0, 0, 0.9))


func _draw_object() -> void:
	var w := size.x
	var h := size.y
	match icon_id:
		"mug":
			draw_arc(Vector2(w * 0.66, h * 0.6), h * 0.09, 0.0, TAU, 20, silhouette, 4.0)
			draw_rect(Rect2(w * 0.25, h * 0.42, w * 0.4, h * 0.38), silhouette)
			for i in 3:
				var x := w * (0.32 + 0.12 * i)
				draw_polyline(PackedVector2Array([
					Vector2(x, h * 0.36), Vector2(x + 4, h * 0.3), Vector2(x - 2, h * 0.24), Vector2(x + 3, h * 0.18),
				]), silhouette.darkened(0.2), 2.0)
		"plant":
			draw_line(Vector2(w * 0.5, h * 0.62), Vector2(w * 0.5, h * 0.35), silhouette.darkened(0.3), 3.0)
			for leaf in [Vector2(0.38, 0.46), Vector2(0.62, 0.42), Vector2(0.5, 0.3)]:
				draw_circle(Vector2(w * leaf.x, h * leaf.y), w * 0.13, silhouette)
			draw_colored_polygon(PackedVector2Array([
				Vector2(w * 0.3, h * 0.62), Vector2(w * 0.7, h * 0.62),
				Vector2(w * 0.64, h * 0.9), Vector2(w * 0.36, h * 0.9),
			]), silhouette.darkened(0.35))
		"stapler":
			draw_rect(Rect2(w * 0.15, h * 0.66, w * 0.7, h * 0.08), silhouette.darkened(0.35))
			draw_colored_polygon(PackedVector2Array([
				Vector2(w * 0.15, h * 0.63), Vector2(w * 0.8, h * 0.5),
				Vector2(w * 0.86, h * 0.57), Vector2(w * 0.2, h * 0.67),
			]), silhouette)
			draw_circle(Vector2(w * 0.19, h * 0.65), w * 0.04, _dark())
		"paper":
			var rx := w * 0.25
			draw_rect(Rect2(w * 0.7, h * 0.5, w * 0.12, h * 0.36), silhouette.lightened(0.15))
			for i in 3:
				var y := h * (0.6 + 0.09 * i)
				draw_line(Vector2(w * 0.7, y), Vector2(w * 0.82, y), _dark(), 1.0)
			_draw_ellipse(Vector2(w * 0.5, h * 0.75), rx, rx * 0.35, silhouette.darkened(0.2))
			draw_rect(Rect2(w * 0.25, h * 0.35, w * 0.5, h * 0.4), silhouette)
			_draw_ellipse(Vector2(w * 0.5, h * 0.35), rx, rx * 0.35, silhouette.lightened(0.2))
			_draw_ellipse(Vector2(w * 0.5, h * 0.35), rx * 0.35, rx * 0.12, _dark())


func _draw_ellipse(center: Vector2, radius_x: float, radius_y: float, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(1.0, radius_y / radius_x))
	draw_circle(Vector2.ZERO, radius_x, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
