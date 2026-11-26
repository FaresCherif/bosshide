class_name SaveData
extends RefCounted

# Sauvegarde de la progression dans un ConfigFile : niveaux debloques, meilleurs scores
# et icone du badge. Les scores de la partie en cours ne sont pas sauves.
# Un fichier absent ou illisible donne les valeurs par defaut ; les valeurs fausses
# sont ignorees une a une par LevelSequence.restore et EmployeeProfile.select.

const DEFAULT_PATH := "user://save.cfg"

# Les tests le detournent vers un autre fichier (tests/pre_run_hook.gd)
static var path := DEFAULT_PATH


static func load_into(sequence: LevelSequence, profile: EmployeeProfile, file_path := "") -> void:
	var config := ConfigFile.new()
	if config.load(_resolve(file_path)) != OK:
		return
	var unlocked: Variant = config.get_value("progress", "unlocked", 1)
	var best_scores: Variant = config.get_value("progress", "best_scores", {})
	sequence.restore(unlocked if unlocked is int else 1, best_scores if best_scores is Dictionary else {})
	var icon: Variant = config.get_value("profile", "icon", EmployeeProfile.DEFAULT_ICON)
	if icon is String:
		profile.select(icon)


static func save(sequence: LevelSequence, profile: EmployeeProfile, file_path := "") -> Error:
	var config := ConfigFile.new()
	config.set_value("progress", "unlocked", sequence.unlocked_count())
	config.set_value("progress", "best_scores", sequence.best_scores_by_number())
	config.set_value("profile", "icon", profile.icon_id())
	return config.save(_resolve(file_path))


static func erase(file_path := "") -> void:
	var target := _resolve(file_path)
	if FileAccess.file_exists(target):
		DirAccess.remove_absolute(target)


static func _resolve(file_path: String) -> String:
	return file_path if file_path != "" else path
