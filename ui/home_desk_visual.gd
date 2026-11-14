@tool
class_name HomeDeskVisual
extends Control

# Bureau du joueur au point de depart : meuble bleu comme les autres bureaux (on peut
# s'y cacher), avec un ecran allume, un mug, une pile TODO et une plaque YOU.
# La photo du badge est un enfant IdPhoto pose dessus (affichage seulement).

const DESK_COLOR := Color(0.15, 0.3, 0.7, 1)
const TOP_Y := 52.0
const INK := Color(0.1, 0.1, 0.12, 1)


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	# Meuble : plateau et facade
	draw_rect(Rect2(0, TOP_Y, size.x, size.y - TOP_Y), DESK_COLOR)
	draw_rect(Rect2(-3, TOP_Y - 4, size.x + 6, 6), DESK_COLOR.lightened(0.2))
	# Ecran allume sur son pied
	draw_rect(Rect2(2, 8, 36, 30), INK)
	draw_rect(Rect2(5, 11, 30, 24), Color(0.35, 0.6, 0.85, 1))
	for i in 3:
		draw_line(Vector2(9, 16 + i * 6), Vector2(28 - i * 5, 16 + i * 6), Color(0.85, 0.92, 1, 1), 2.0)
	draw_rect(Rect2(17, 38, 6, 10), INK)
	draw_rect(Rect2(10, 46, 20, 4), INK)
	# Pile de dossiers TODO
	for i in 3:
		draw_rect(Rect2(42, 44 - i * 4, 18, 4), [Color(0.95, 0.95, 0.9), Color(0.95, 0.85, 0.4), Color(0.9, 0.9, 0.85)][i])
	draw_string(get_theme_default_font(), Vector2(40, 33), "TODO", HORIZONTAL_ALIGNMENT_CENTER, 22, 9, Color(0.9, 0.3, 0.3, 1))
	# Mug fumant
	draw_rect(Rect2(63, 40, 11, 12), Color(0.9, 0.9, 0.88, 1))
	draw_arc(Vector2(75, 46), 3.5, -PI / 2.0, PI / 2.0, 8, Color(0.9, 0.9, 0.88, 1), 2.0)
	draw_line(Vector2(67, 36), Vector2(69, 31), Color(1, 1, 1, 0.6), 1.5)
	draw_line(Vector2(71, 36), Vector2(70, 30), Color(1, 1, 1, 0.6), 1.5)
	# Plaque YOU sur la facade
	var plate := Rect2(size.x / 2.0 - 16, TOP_Y + 14, 32, 14)
	draw_rect(plate, Color(0.85, 0.75, 0.35, 1))
	draw_string(get_theme_default_font(), Vector2(plate.position.x, plate.end.y - 3), "YOU", HORIZONTAL_ALIGNMENT_CENTER, plate.size.x, 11, INK)
