class_name LevelResult
extends RefCounted

# Textes des ecrans de fin de niveau, calcules sans dependre de l'arbre


# Le patron se doute de tout mais ne peut rien prouver : tampon vert au bas du ticket
const APPROVAL_STAMP := "NO EVIDENCE"

# Phrase sous le titre, tiree au hasard a chaque niveau
const SUSPICIONS := [
	"Nobody saw you slack off. Officially.",
	"No witnesses. No evidence. No productivity.",
	"Your chair was still warm. The boss noticed.",
	"The boss saw nothing. That worries him.",
	"Badge says: at desk. The boss says: hmm.",
]

# Note du patron en pied de ticket, tiree au hasard a chaque niveau
const BOSS_NOTES := [
	"Boss's note: I know it was you. I just can't prove it. Yet.",
	"Boss's note: \"Printer jam\" for 12 minutes. Sure.",
	"Boss's note: Looked for you everywhere. \"In a meeting.\" Hmm.",
	"Boss's note: Same smile as yesterday. Too relaxed. Watch closely.",
	"Boss's note: 3 people swear you were working. All 3 owe you money.",
]


static func pick(lines: Array, rng: RandomNumberGenerator) -> String:
	return lines[rng.randi_range(0, lines.size() - 1)]


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
