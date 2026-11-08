class_name ManagerPatrol
extends RefCounted

enum State { PATROL, ATTRACTED, WAITING, RETURNING }

const SPEED := 150.0
const ATTRACT_WAIT := 3.0

var _left_limit: float
var _right_limit: float
var _x: float
var _direction := -1
var _state := State.PATROL
var _target := 0.0
var _wait := 0.0


func _init(left_limit: float, right_limit: float) -> void:
	_left_limit = left_limit
	_right_limit = right_limit
	_x = right_limit


func get_x() -> float:
	return _x


func get_direction() -> int:
	return _direction


func is_attracted() -> bool:
	return _state != State.PATROL


# Le manager quitte sa ronde pour aller voir la cible, meme hors de ses limites
func attract(target_x: float) -> void:
	_target = target_x
	_state = State.ATTRACTED


func update(delta: float) -> void:
	match _state:
		State.PATROL:
			_patrol(delta)
		State.ATTRACTED:
			if _move_toward(_target, delta):
				_state = State.WAITING
				_wait = ATTRACT_WAIT
		State.WAITING:
			_wait -= delta
			if _wait <= 0.0:
				_target = clampf(_x, _left_limit, _right_limit)
				_state = State.PATROL if _target == _x else State.RETURNING
		State.RETURNING:
			if _move_toward(_target, delta):
				_state = State.PATROL


# Avance le manager : le trop-parcouru apres une limite est reporte dans l'autre sens
func _patrol(delta: float) -> void:
	_x += _direction * SPEED * delta
	while _x < _left_limit or _x > _right_limit:
		if _x < _left_limit:
			_x = 2.0 * _left_limit - _x
			_direction = 1
		else:
			_x = 2.0 * _right_limit - _x
			_direction = -1


# Marche vers la cible sans la depasser ; renvoie true une fois arrive
func _move_toward(target: float, delta: float) -> bool:
	if target != _x:
		_direction = 1 if target > _x else -1
	_x = move_toward(_x, target, SPEED * delta)
	return _x == target
