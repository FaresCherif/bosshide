class_name LevelSequence
extends RefCounted

var _paths: Array
var _index := 0
var _scores := {}
# Deblocages de la session : rien n'est sauvegarde a la fermeture
var _unlocked := 1
var _best_scores := {}


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


func unlocked_count() -> int:
	return _unlocked


func is_unlocked(number: int) -> bool:
	return number >= 1 and number <= _unlocked


# Choisit un niveau debloque (numero a partir de 1) comme niveau courant
func select(number: int) -> bool:
	if not is_unlocked(number):
		return false
	_index = number - 1
	return true


# Rejouer un niveau remplace son score ; une reussite debloque le niveau suivant
func record_score(score: int) -> void:
	if is_finished():
		return
	_scores[_index] = score
	_best_scores[_index] = maxi(score, _best_scores.get(_index, score))
	_unlocked = clampi(_index + 2, _unlocked, _paths.size())


func has_best_score(number: int) -> bool:
	return _best_scores.has(number - 1)


func best_score(number: int) -> int:
	return _best_scores.get(number - 1, 0)


func total_score() -> int:
	var total := 0
	for score: int in _scores.values():
		total += score
	return total


func advance() -> void:
	_index = mini(_index + 1, _paths.size())


# Revient au niveau 1 et efface les scores, mais garde les deblocages et les meilleurs scores
func restart_all() -> void:
	_index = 0
	_scores.clear()
