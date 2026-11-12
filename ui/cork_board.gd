@tool
class_name CorkBoard
extends Control

# Tableau d'affichage en liege avec un cadre en bois (affichage seulement)

@export var frame_width := 18.0
@export var frame_color := Color(0.45, 0.28, 0.15, 1)
@export var cork_color := Color(0.78, 0.6, 0.4, 1)
@export var speckle_count := 260
@export var speckle_seed := 7


func _ready() -> void:
	resized.connect(queue_redraw)


func cork_rect() -> Rect2:
	var inset := Vector2(frame_width, frame_width)
	return Rect2(inset, size - inset * 2.0)


# Grains du liege : toujours les memes grace a la graine fixe
func speckles() -> PackedVector2Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = speckle_seed
	var cork := cork_rect()
	var points := PackedVector2Array()
	for i in speckle_count:
		points.append(cork.position + Vector2(rng.randf() * cork.size.x, rng.randf() * cork.size.y))
	return points


func _draw() -> void:
	draw_rect(Rect2(Vector2(8, 10), size), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(Vector2.ZERO, size), frame_color)
	draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), frame_color.lightened(0.15), false, 2.0)
	var cork := cork_rect()
	draw_rect(cork, cork_color)
	var i := 0
	for point in speckles():
		var shade := cork_color.darkened(0.3) if i % 3 else cork_color.lightened(0.2)
		draw_circle(point, 1.5 + (i % 2), shade)
		i += 1
	draw_rect(cork, frame_color.darkened(0.3), false, 3.0)
