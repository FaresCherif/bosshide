class_name HrWarning
extends RefCounted

# Textes de l'avertissement des RH affiche au game over, calcules sans l'arbre

enum Spotter { WATCHING, PATROLLING }

# Une sanction fixe par niveau, reprise depuis le debut apres la derniere
const SANCTIONS := [
	"Mandatory team-building weekend.",
	"Unpaid overtime until further notice.",
	"Desk moved next to the boss.",
	"Weekly 8 a.m. synergy meeting.",
	"Toilet access now requires a badge.",
	"Write a 40-page report explaining yourself.",
]


static func checkbox(checked: bool, text: String) -> String:
	return ("[X] " if checked else "[  ] ") + text


static func spotted_by(spotter: Spotter) -> Array:
	return [
		checkbox(spotter == Spotter.WATCHING, "The boss (watching)"),
		checkbox(spotter == Spotter.PATROLLING, "The boss (patrolling)"),
	]


static func reasons(has_key: bool, knows_code: bool) -> Array:
	return [
		checkbox(true, "Not at desk"),
		checkbox(has_key, "In possession of a stolen key"),
		checkbox(knows_code, "Knows confidential codes"),
	]


static func stats(time_text: String, wrong_codes: int, wrong_answers: int) -> String:
	return "Time: %s - Wrong codes: %d - Wrong answers: %d" % [time_text, wrong_codes, wrong_answers]


# Un niveau lance seul (numero 0) prend la premiere sanction
static func sanction(level_number: int) -> String:
	return SANCTIONS[maxi(level_number - 1, 0) % SANCTIONS.size()]


static func form_text(spotter: Spotter, has_key: bool, knows_code: bool, level_number: int) -> String:
	var lines := ["Spotted by:"]
	lines.append_array(spotted_by(spotter))
	lines.append("Reason:")
	lines.append_array(reasons(has_key, knows_code))
	lines.append("Sanction: " + sanction(level_number))
	return "\n".join(lines)
