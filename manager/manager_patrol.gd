class_name ManagerPatrol
extends RefCounted

const SPEED := 150.0

var _left_limit: float
var _right_limit: float
var _x: float
var _direction := -1


func _init(left_limit: float, right_limit: float) -> void:
	_left_limit = left_limit
	_right_limit = right_limit
	_x = right_limit


func get_x() -> float:
	return _x


func get_direction() -> int:
	return _direction


# Avance le manager : le trop-parcouru apres une limite est reporte dans l'autre sens
func update(delta: float) -> void:
	_x += _direction * SPEED * delta
	while _x < _left_limit or _x > _right_limit:
		if _x < _left_limit:
			_x = 2.0 * _left_limit - _x
			_direction = 1
		else:
			_x = 2.0 * _right_limit - _x
			_direction = -1
