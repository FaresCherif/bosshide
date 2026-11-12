@tool
class_name IdPhoto
extends Control

# Photo d'identite du badge, facon camera de surveillance : fond vert sombre,
# silhouette et lignes de balayage (affichage seulement)

@export var background := Color(0.08, 0.16, 0.1, 1)
@export var silhouette := Color(0.45, 0.75, 0.5, 1)
@export var scanline_color := Color(0, 0, 0, 0.25)
@export var scanline_spacing := 4.0


func _ready() -> void:
	resized.connect(queue_redraw)


func head_radius() -> float:
	return minf(size.x, size.y) * 0.2


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), background)
	var radius := head_radius()
	var head := Vector2(size.x / 2.0, size.y * 0.4)
	# Epaules : un demi-disque large en bas de la photo
	var shoulders := Vector2(size.x / 2.0, size.y + radius * 0.6)
	draw_circle(shoulders, radius * 2.1, silhouette.darkened(0.15))
	draw_circle(head, radius, silhouette)
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), scanline_color, 1.0)
		y += scanline_spacing
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6), false, 2.0)
