class_name ColleagueQuiz
extends RefCounted

enum Result { IGNORED, WRONG, RIGHT }
enum State { IDLE, TALKING, DONE }

var _question: Dictionary
var _state := State.IDLE


func _init(question: Dictionary) -> void:
	_question = question


static func pick_question(questions: Array, rng: RandomNumberGenerator) -> Dictionary:
	return questions[rng.randi_range(0, questions.size() - 1)]


func question() -> Dictionary:
	return _question


# Le collegue n'interpelle le joueur qu'une seule fois
func start() -> bool:
	if _state != State.IDLE:
		return false
	_state = State.TALKING
	return true


func is_talking() -> bool:
	return _state == State.TALKING


func is_done() -> bool:
	return _state == State.DONE


# Choix entre 0 et 2 : toute reponse valide termine la conversation
func answer(choice: int) -> Result:
	if _state != State.TALKING or choice < 0 or choice >= _question["choices"].size():
		return Result.IGNORED
	_state = State.DONE
	return Result.RIGHT if choice == _question["answer"] else Result.WRONG
