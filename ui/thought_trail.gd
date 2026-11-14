@tool
class_name ThoughtTrail
extends Control

# Trainee de ronds d'une pensee de BD : en ligne droite de la tete du personnage
# jusqu'aux bulles, regulierement espaces et de plus en plus gros (affichage seulement).
# from et to sont dans le repere de ce noeud.

const COUNT := 4
const MIN_RADIUS := 4.0
const MAX_RADIUS := 9.0
# Part du trajet tete-bulles ou sont le premier et le dernier rond
const START := 0.18
const END := 0.9
const FILL := Color(1, 1, 1, 1)
const INK := Color(0.17, 0.17, 0.2, 1)

@export var from := Vector2.ZERO:
	set(value):
		from = value
		queue_redraw()
@export var to := Vector2.ZERO:
	set(value):
		to = value
		queue_redraw()


# Ronds (x, y, rayon), du plus proche de la tete au plus proche des bulles.
# Ils laissent un peu de vide pres de la tete et finissent pres des bulles.
static func dots(start: Vector2, end: Vector2) -> Array[Vector3]:
	var result: Array[Vector3] = []
	for i in COUNT:
		var t := lerpf(START, END, float(i) / float(COUNT - 1))
		var point := start.lerp(end, t)
		var radius := lerpf(MIN_RADIUS, MAX_RADIUS, float(i) / float(COUNT - 1))
		result.append(Vector3(point.x, point.y, radius))
	return result


func _draw() -> void:
	for dot in dots(from, to):
		draw_circle(Vector2(dot.x, dot.y), dot.z + 2.0, INK)
		draw_circle(Vector2(dot.x, dot.y), dot.z, FILL)
