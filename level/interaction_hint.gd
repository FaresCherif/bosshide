class_name InteractionHint
extends RefCounted

# Ce que fait la touche E selon la position du joueur, sans dependre de l'arbre.
# Le niveau s'en sert a la fois pour agir et pour afficher l'indice, qui dit donc
# toujours ce que E va faire.

enum Action { NONE, TYPE_CODE, READ_CODE, OPEN_DOOR, LOCKED_DOOR, TAKE_KEY, WORK, STOP_WORK }

const LABELS := {
	Action.NONE: "",
	Action.TYPE_CODE: "E: type the code",
	Action.READ_CODE: "E: read the post-it",
	Action.OPEN_DOOR: "E: open the door",
	Action.LOCKED_DOOR: "Locked - find the key",
	Action.TAKE_KEY: "E: grab the key",
	Action.WORK: "E: pretend to work",
	Action.STOP_WORK: "E: stop pretending",
}


# Cles de state : can_act, at_keypad (porte du digicode fermee et a portee), on_post_it,
# at_door, door_open, has_key, on_key (cle encore sur le bureau et a portee), working, on_desk.
# L'ordre suit les priorites de la touche E : digicode, post-it, porte, cle, bureau.
static func resolve(state: Dictionary) -> Action:
	if not state["can_act"]:
		return Action.NONE
	if state["at_keypad"]:
		return Action.TYPE_CODE
	if state["on_post_it"]:
		return Action.READ_CODE
	var door_closed: bool = state["at_door"] and not state["door_open"]
	if door_closed and state["has_key"]:
		return Action.OPEN_DOOR
	if state["on_key"]:
		return Action.TAKE_KEY
	if door_closed:
		return Action.LOCKED_DOOR
	if state["working"]:
		return Action.STOP_WORK
	if state["on_desk"]:
		return Action.WORK
	return Action.NONE


static func label(action: Action) -> String:
	return LABELS[action]
