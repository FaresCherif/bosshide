@tool
class_name ToiletPaper
extends Control

# Distributeur de papier toilette fixe en haut, et bande qui en sort jusqu'en bas
# (feuilles predecoupees, bord dechire). Affichage seulement : le texte imprime
# sur le papier est fait de Labels poses par-dessus.

const UNROLL_DURATION := 0.8
# 4 feuilles sur l'ecran de reussite : titre, resultats, tampon, pied
const SHEET_HEIGHT := 136.0
const TOOTH := 9.0
# Distributeur : hauteur, et part de la bande cachee dans sa fente
const DISPENSER_HEIGHT := 84.0
const SLOT_DEPTH := 10.0
const STRIP_MARGIN := 30.0

const PAPER := Color(0.98, 0.97, 0.93)
const PAPER_SHADE := Color(0.88, 0.86, 0.8)
const PERFORATION := Color(0.7, 0.68, 0.62)
const METAL := Color(0.78, 0.8, 0.82)
const METAL_DARK := Color(0.45, 0.47, 0.5)
const SHADOW := Color(0, 0, 0, 0.3)

# Part deroulee de la bande, de 0 (tout dans le distributeur) a 1
@export_range(0.0, 1.0) var unrolled := 1.0:
	set(value):
		unrolled = clampf(value, 0.0, 1.0)
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


# Hauteurs des pointilles entre deux feuilles, depuis le haut de la bande (pas au bout)
static func perforations(length: float, sheet: float) -> PackedFloat32Array:
	var lines := PackedFloat32Array()
	var y := sheet
	while y < length - 0.5:
		lines.append(y)
		y += sheet
	return lines


# Quand une ligne a la hauteur y de la bande doit apparaitre pendant le deroulement
static func reveal_delay(y: float, length: float, duration: float) -> float:
	if length <= 0.0:
		return 0.0
	return clampf(y / length, 0.0, 1.0) * duration


# Bord dechire en dents de scie, de gauche a droite, les pointes en bas a y
static func tear_points(width: float, y: float, tooth: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var count := maxi(2, int(round(width / tooth)))
	for i in count + 1:
		var x := width * i / count
		points.append(Vector2(x, y if i % 2 == 0 else y - tooth))
	return points


func full_length() -> float:
	return size.y - DISPENSER_HEIGHT + SLOT_DEPTH


func strip_length() -> float:
	return full_length() * unrolled


# Bande entierement deroulee, dans l'ecran : la zone ou le texte est imprime
func strip_global_rect() -> Rect2:
	return Rect2(global_position + _strip_origin(), Vector2(_strip_width(), full_length()))


func _strip_origin() -> Vector2:
	return Vector2(STRIP_MARGIN, DISPENSER_HEIGHT - SLOT_DEPTH)


func _strip_width() -> float:
	return size.x - STRIP_MARGIN * 2.0


# Deroule la bande et fait apparaitre chaque Label quand le papier arrive a sa hauteur
func unroll(labels: Array[Control]) -> Tween:
	unrolled = 0.0
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "unrolled", 1.0, UNROLL_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var top := global_position.y + _strip_origin().y
	for label in labels:
		label.modulate.a = 0.0
		var delay := reveal_delay(label.global_position.y - top, full_length(), UNROLL_DURATION)
		tween.tween_property(label, "modulate:a", 1.0, 0.15).set_delay(delay)
	return tween


func _draw() -> void:
	_draw_strip()
	_draw_dispenser()


func _draw_strip() -> void:
	var origin := _strip_origin()
	var width := _strip_width()
	var length := strip_length()
	if length <= 0.0:
		return
	var bottom := origin.y + length
	var outline := PackedVector2Array([origin, origin + Vector2(width, 0)])
	# Le bord dechire n'apparait qu'une fois la bande arrachee, au bout du deroulement
	var edge := tear_points(width, bottom, TOOTH) if unrolled >= 1.0 else PackedVector2Array([Vector2(0, bottom), Vector2(width, bottom)])
	for i in range(edge.size() - 1, -1, -1):
		outline.append(edge[i] + Vector2(origin.x, 0))
	var shadow := PackedVector2Array()
	for point in outline:
		shadow.append(point + Vector2(8, 6))
	draw_colored_polygon(shadow, SHADOW)
	draw_colored_polygon(outline, PAPER)
	# Ombre du rouleau sur le haut de la bande, et relief gaufre sur les bords
	draw_rect(Rect2(origin, Vector2(width, 18)), Color(PAPER_SHADE, 0.6))
	for y in range(int(origin.y) + 6, int(bottom) - 6, 14):
		draw_circle(Vector2(origin.x + 8, y), 1.5, PAPER_SHADE)
		draw_circle(Vector2(origin.x + width - 8, y), 1.5, PAPER_SHADE)
	for line in perforations(length, SHEET_HEIGHT):
		var y := origin.y + line
		draw_dashed_line(Vector2(origin.x, y), Vector2(origin.x + width, y), PERFORATION, 2.0, 6.0)


func _draw_dispenser() -> void:
	var body := Rect2(Vector2.ZERO, Vector2(size.x, DISPENSER_HEIGHT))
	draw_rect(Rect2(body.position + Vector2(6, 6), body.size), SHADOW)
	draw_rect(body, METAL)
	# Reflet, fente d'ou sort le papier et vis aux coins
	draw_rect(Rect2(Vector2(10, 8), Vector2(size.x - 20, 6)), Color(1, 1, 1, 0.5))
	draw_rect(Rect2(Vector2(STRIP_MARGIN - 6, DISPENSER_HEIGHT - SLOT_DEPTH - 4), Vector2(_strip_width() + 12, 6)), METAL_DARK)
	draw_rect(body, METAL_DARK, false, 3.0)
	for corner in [Vector2(14, 14), Vector2(size.x - 14, 14), Vector2(14, DISPENSER_HEIGHT - 26), Vector2(size.x - 14, DISPENSER_HEIGHT - 26)]:
		draw_circle(corner, 4.0, METAL_DARK)
		draw_line(corner - Vector2(3, 0), corner + Vector2(3, 0), METAL, 1.5)
