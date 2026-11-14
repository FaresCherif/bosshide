@tool
class_name DashedLine
extends Control

# Trait horizontal en pointilles au milieu du noeud (affichage seulement)

@export var color := Color(0.17, 0.17, 0.2, 0.35)
@export var width := 1.5
@export var dash := 6.0


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var y := size.y / 2.0
	draw_dashed_line(Vector2(0, y), Vector2(size.x, y), color, width, dash)
