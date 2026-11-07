class_name PlayerWork
extends RefCounted

var _working := false


func is_working() -> bool:
	return _working


# Le joueur appuie sur la touche de travail : commencer demande d'etre sur un bureau
func press_work(on_desk: bool) -> void:
	_working = not _working and on_desk


func stop() -> void:
	_working = false


# Direction entre -1 et 1 reellement appliquee : le joueur est immobile au travail
func allowed_direction(direction: float) -> float:
	return 0.0 if _working else direction
