@tool
class_name PushPin
extends Control

# Punaise vue de dessus : ombre, tete ronde et reflet (affichage seulement)

@export var color := Color(0.843, 0.149, 0.239, 1)


func _ready() -> void:
	resized.connect(queue_redraw)


func head_radius() -> float:
	return minf(size.x, size.y) * 0.38


func _draw() -> void:
	var center := size / 2.0
	var radius := head_radius()
	draw_circle(center + Vector2(4, 5), radius, Color(0, 0, 0, 0.3))
	draw_circle(center, radius, color.darkened(0.25))
	draw_circle(center - Vector2(1, 1), radius * 0.85, color)
	draw_circle(center - Vector2(radius, radius) * 0.35, radius * 0.25, Color(1, 1, 1, 0.6))
