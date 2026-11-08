class_name DoorKey
extends RefCounted

var _key_on_desk := true
var _has_key := false
var _door_open := false


func is_key_on_desk() -> bool:
	return _key_on_desk


func has_key() -> bool:
	return _has_key


func is_door_open() -> bool:
	return _door_open


# La cle passe du bureau au joueur
func take_key() -> bool:
	if not _key_on_desk:
		return false
	_key_on_desk = false
	_has_key = true
	return true


# La porte s'ouvre seulement avec la cle, qui est alors consommee
func open_door() -> bool:
	if not _has_key or _door_open:
		return false
	_has_key = false
	_door_open = true
	return true


# Appui sur la touche d'action : renvoie true si la porte ou la cle l'a utilise,
# sinon l'appui sert a travailler
func interact(at_door: bool, on_key: bool) -> bool:
	if at_door and open_door():
		return true
	return on_key and take_key()
