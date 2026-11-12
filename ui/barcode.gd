@tool
class_name Barcode
extends Control

# Code-barre du badge : barres noires d'epaisseurs variees (affichage seulement)

@export var bar_color := Color(0.1, 0.1, 0.1, 1)
@export var barcode_seed := 4012
@export var unit := 2.0


func _ready() -> void:
	resized.connect(queue_redraw)


# Largeurs alternees barre / espace, toujours les memes grace a la graine fixe,
# sans depasser la largeur du noeud
func bar_widths() -> PackedFloat32Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = barcode_seed
	var widths := PackedFloat32Array()
	var total := 0.0
	while true:
		var width := unit * rng.randi_range(1, 3)
		if total + width > size.x:
			break
		widths.append(width)
		total += width
	return widths


func _draw() -> void:
	var x := 0.0
	var i := 0
	for width in bar_widths():
		if i % 2 == 0:
			draw_rect(Rect2(x, 0, width, size.y), bar_color)
		x += width
		i += 1
