class_name ManagerWatch
extends RefCounted

const FACING_DURATION := 10.0
const BACK_DURATION := 5.0

var _facing := true
var _time_left := FACING_DURATION


func is_facing() -> bool:
	return _facing


# Avance le cycle : le temps en trop est reporte sur les phases suivantes
func update(delta: float) -> void:
	_time_left -= delta
	while _time_left <= 0.0:
		_facing = not _facing
		_time_left += FACING_DURATION if _facing else BACK_DURATION
