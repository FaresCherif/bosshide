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
	return "Finish" if is_last else "Next"
