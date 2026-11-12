@tool
class_name OfficeClock
extends Control

# Pendule de bureau a l'heure du PC (affichage seulement)

@export var face_color := Color(0.98, 0.98, 0.96, 1)
@export var rim_color := Color(0.15, 0.15, 0.17, 1)
@export var hand_color := Color(0.15, 0.15, 0.17, 1)
@export var second_color := Color(0.85, 0.15, 0.2, 1)

var _time := Vector3i(-1, -1, -1)


# Angles des aiguilles (heures, minutes, secondes) en radians depuis midi, sur 12 heures
static func hand_angles(hour: int, minute: int, second: int) -> Vector3:
	var seconds := second / 60.0
	var minutes := (minute + seconds) / 60.0
	var hours := ((hour % 12) + minutes) / 12.0
	return Vector3(hours * TAU, minutes * TAU, seconds * TAU)


func set_time(hour: int, minute: int, second: int) -> void:
	_time = Vector3i(hour, minute, second)
	queue_redraw()


func displayed_time() -> Vector3i:
	return _time


func _process(_delta: float) -> void:
	var now := Time.get_time_dict_from_system()
	if now["second"] != _time.z or now["minute"] != _time.y or now["hour"] != _time.x:
		set_time(now["hour"], now["minute"], now["second"])


func _draw() -> void:
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - 2.0
	draw_circle(center + Vector2(4, 5), radius, Color(0, 0, 0, 0.25))
	draw_circle(center, radius, rim_color)
	draw_circle(center, radius * 0.88, face_color)
	for i in 12:
		var direction := Vector2.UP.rotated(i * TAU / 12.0)
		var inner := 0.7 if i % 3 == 0 else 0.76
		draw_line(center + direction * radius * inner, center + direction * radius * 0.82, rim_color, 3.0 if i % 3 == 0 else 1.5)
	if _time.x < 0:
		return
	var angles := hand_angles(_time.x, _time.y, _time.z)
	draw_line(center, center + Vector2.UP.rotated(angles.x) * radius * 0.45, hand_color, 5.0)
	draw_line(center, center + Vector2.UP.rotated(angles.y) * radius * 0.68, hand_color, 3.0)
	draw_line(center - Vector2.UP.rotated(angles.z) * radius * 0.15, center + Vector2.UP.rotated(angles.z) * radius * 0.75, second_color, 1.5)
	draw_circle(center, radius * 0.06, second_color)
