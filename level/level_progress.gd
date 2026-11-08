class_name LevelProgress
extends RefCounted

var _finished := false
var _game_over := false


func is_finished() -> bool:
	return _finished


func is_game_over() -> bool:
	return _game_over


# Le joueur a atteint l'arrivee : le niveau reste termine jusqu'a la relance
func reach_goal() -> void:
	_finished = true


# Le joueur a ete vu : sans effet si le niveau est deja termine
func fail() -> void:
	if _finished:
		return
	_finished = true
	_game_over = true


func can_move() -> bool:
	return not _finished


func can_restart() -> bool:
	return _finished


# Seule une reussite permet de passer au niveau suivant
func can_continue() -> bool:
	return _finished and not _game_over
