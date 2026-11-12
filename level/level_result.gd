class_name LevelResult
extends RefCounted

# Textes des ecrans de fin de niveau, calcules sans dependre de l'arbre


# Un niveau lance seul (sans le jeu) n'a pas de numero : 0
static func success_title(number: int) -> String:
	if number <= 0:
		return "Level complete!"
	return "Level %d complete!" % number


static func details(time_text: String, score: int) -> String:
	return "Time: %s - Score: %d" % [time_text, score]


static func time_only(time_text: String) -> String:
	return "Time: %s" % time_text


static func best_line(best: int, is_new: bool) -> String:
	if is_new:
		return "New best! Best: %d" % best
	return "Best: %d" % best


static func next_label(is_last: bool) -> String:
	return "Clock out" if is_last else "Next mission"


# Grade d'employe selon le score : le pire score est le chouchou du patron
const RANKS := [
	[900, "Toilet Ninja"],
	[700, "Professional Slacker"],
	[500, "Coffee Break Specialist"],
	[250, "Overworked Intern"],
]
const WORST_RANK := "Employee of the Month"


static func rank(score: int) -> String:
	for entry in RANKS:
		if score >= entry[0]:
			return entry[1]
	return WORST_RANK


static func rank_line(score: int) -> String:
	return "Rank: %s" % rank(score)
