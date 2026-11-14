class_name QuizReaction
extends RefCounted

# Reaction apres la reponse au collegue : un court moment ou la reponse choisie
# s'affiche en vert ou en rouge barre avant de fermer les bulles. Le joueur est deja
# libre et peut etre repere pendant ce temps.

const DURATION := 1.2
const RIGHT_COLOR := Color(0.15, 0.6, 0.3, 1)
const WRONG_COLOR := Color(0.85, 0.15, 0.2, 1)
const FADED_ALPHA := 0.35

var _remaining := 0.0
var _result := ColleagueQuiz.Result.IGNORED


func start(result: ColleagueQuiz.Result) -> void:
	_result = result
	_remaining = DURATION


func update(delta: float) -> void:
	_remaining = maxf(_remaining - delta, 0.0)


func is_active() -> bool:
	return _remaining > 0.0


func result() -> ColleagueQuiz.Result:
	return _result


# Style d'une ligne de reponse : la ligne choisie prend la couleur du resultat,
# les autres s'estompent
static func row_style(index: int, chosen: int, result: ColleagueQuiz.Result) -> Dictionary:
	if index != chosen:
		return {"color": Color(0.17, 0.17, 0.2, 1), "alpha": FADED_ALPHA, "struck": false}
	var right := result == ColleagueQuiz.Result.RIGHT
	return {"color": RIGHT_COLOR if right else WRONG_COLOR, "alpha": 1.0, "struck": not right}
