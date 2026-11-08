class_name PlayerWork
extends RefCounted

var _working := false
var _busy := false


func is_working() -> bool:
	return _working


# Le joueur appuie sur la touche de travail : commencer demande d'etre sur un bureau
func press_work(on_desk: bool) -> void:
	_working = not _working and on_desk


func stop() -> void:
	_working = false


# Occupe (par exemple au digicode), le joueur ne bouge pas mais reste visible
func set_busy(busy: bool) -> void:
	_busy = busy


# Direction entre -1 et 1 reellement appliquee : le joueur est immobile au travail ou occupe
func allowed_direction(direction: float) -> float:
	return 0.0 if _working or _busy else direction
