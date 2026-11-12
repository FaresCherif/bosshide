class_name DoorCode
extends RefCounted

enum Result { IGNORED, WRONG, RIGHT }

const LENGTH := 4

var _code: String
var _entry := ""
var _code_shown := false
var _code_read := false
var _keypad_open := false
var _door_open := false


func _init(code: String) -> void:
	_code = code


static func random_code(rng: RandomNumberGenerator) -> String:
	var code := ""
	for i in LENGTH:
		code += str(rng.randi_range(0, 9))
	return code


func code() -> String:
	return _code


# Le code n'est visible que pendant que le joueur est devant le post-it
func read() -> void:
	_code_shown = true
	_code_read = true


# Le joueur a deja lu le post-it au moins une fois
func has_read_code() -> bool:
	return _code_read


func stop_reading() -> void:
	_code_shown = false


func is_code_shown() -> bool:
	return _code_shown


func is_door_open() -> bool:
	return _door_open


func is_keypad_open() -> bool:
	return _keypad_open


func open_keypad() -> void:
	_keypad_open = not _door_open
	_entry = ""


func close_keypad() -> void:
	_keypad_open = false
	_entry = ""


func entry() -> String:
	return _entry


func type_digit(digit: int) -> void:
	if _keypad_open and _entry.length() < LENGTH:
		_entry += str(digit)


func erase() -> void:
	_entry = _entry.left(-1)


# Une saisie incomplete est ignoree ; une erreur efface la saisie sans fermer le panneau
func submit() -> Result:
	if not _keypad_open or _entry.length() < LENGTH:
		return Result.IGNORED
	if _entry != _code:
		_entry = ""
		return Result.WRONG
	_door_open = true
	close_keypad()
	return Result.RIGHT
