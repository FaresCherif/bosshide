@tool
class_name RuledStickyStyle
extends StyleBox

# Post-it ligne dessine sous le texte d'un bouton : ombre, bande collante,
# lignes et coin corne (affichage seulement)

@export var bg_color := Color(1, 0.878, 0.4, 1)
@export var line_color := Color(0.3, 0.45, 0.8, 0.35)
@export var shadow_color := Color(0, 0, 0, 0.35)
@export var shadow_offset := Vector2(5, 6)
@export var top_margin := 34.0
@export var bottom_margin := 24.0
@export var spacing := 22.0
@export var fold_size := 18.0


# Hauteurs des lignes dans le rectangle, de la marge du haut a celle du bas
func line_positions(rect: Rect2) -> PackedFloat32Array:
	var ys := PackedFloat32Array()
	var y := rect.position.y + top_margin
	while y <= rect.end.y - bottom_margin:
		ys.append(y)
		y += spacing
	return ys


func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	var rs := RenderingServer
	var fold := minf(fold_size, minf(rect.size.x, rect.size.y) / 2.0)
	var top_left := rect.position
	var bottom_right := rect.end
	var sheet := PackedVector2Array([
		top_left,
		Vector2(bottom_right.x, top_left.y),
		Vector2(bottom_right.x, bottom_right.y - fold),
		Vector2(bottom_right.x - fold, bottom_right.y),
		Vector2(top_left.x, bottom_right.y),
	])
	var shadow := PackedVector2Array()
	for point in sheet:
		shadow.append(point + shadow_offset)
	rs.canvas_item_add_polygon(to_canvas_item, shadow, PackedColorArray([shadow_color]))
	rs.canvas_item_add_polygon(to_canvas_item, sheet, PackedColorArray([bg_color]))
	rs.canvas_item_add_rect(to_canvas_item, Rect2(top_left, Vector2(rect.size.x, minf(10.0, rect.size.y))), bg_color.darkened(0.08))
	for y in line_positions(rect):
		rs.canvas_item_add_line(to_canvas_item, Vector2(top_left.x, y), Vector2(bottom_right.x, y), line_color, 2.0)
	var dog_ear := PackedVector2Array([
		Vector2(bottom_right.x, bottom_right.y - fold),
		Vector2(bottom_right.x - fold, bottom_right.y),
		Vector2(bottom_right.x - fold, bottom_right.y - fold),
	])
	rs.canvas_item_add_polygon(to_canvas_item, dog_ear, PackedColorArray([bg_color.darkened(0.2)]))
