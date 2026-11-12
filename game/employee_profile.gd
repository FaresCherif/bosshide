class_name EmployeeProfile
extends RefCounted

# Profil de l'employe pour la session : l'icone choisie pour sa photo de badge.
# Rien n'est sauvegarde a la fermeture.

const DEFAULT_ICON := "classic"
const ICONS := [
	{"id": "classic", "name": "The Classic"},
	{"id": "tie", "name": "Middle Manager"},
	{"id": "glasses", "name": "The Accountant"},
	{"id": "bun", "name": "Team Lead"},
	{"id": "cap", "name": "The Intern"},
	{"id": "shades", "name": "Undercover"},
	{"id": "mug", "name": "Coffee Addict"},
	{"id": "plant", "name": "Office Plant"},
	{"id": "stapler", "name": "The Stapler"},
	{"id": "paper", "name": "Toilet Roll"},
]

var _icon_id := DEFAULT_ICON


func icon_id() -> String:
	return _icon_id


# Refuse une icone inconnue et garde alors le choix precedent
func select(id: String) -> bool:
	if icon_name(id) == "":
		return false
	_icon_id = id
	return true


static func icon_name(id: String) -> String:
	for icon in ICONS:
		if icon["id"] == id:
			return icon["name"]
	return ""
