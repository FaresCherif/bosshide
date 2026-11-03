class_name LevelProgress
extends RefCounted

var _finished := false


func is_finished() -> bool:
	return _finished


# Le joueur a atteint l'arrivee : le niveau reste termine jusqu'a la relance
func reach_goal() -> void:
	_finished = true


func can_move() -> bool:
	return not _finished


func can_restart() -> bool:
	return _finished
