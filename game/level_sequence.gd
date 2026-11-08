class_name LevelSequence
extends RefCounted

var _paths: Array
var _index := 0
var _scores := {}


func _init(paths: Array) -> void:
	_paths = paths


func current_path() -> String:
	return _paths[_index] if not is_finished() else ""


func level_number() -> int:
	return _index + 1


func level_count() -> int:
	return _paths.size()


func is_last() -> bool:
	return _index == _paths.size() - 1


func is_finished() -> bool:
	return _index >= _paths.size()


# Rejouer un niveau remplace son score
func record_score(score: int) -> void:
	if not is_finished():
		_scores[_index] = score


func total_score() -> int:
	var total := 0
	for score: int in _scores.values():
		total += score
	return total


func advance() -> void:
	_index = mini(_index + 1, _paths.size())


func restart_all() -> void:
	_index = 0
	_scores.clear()
