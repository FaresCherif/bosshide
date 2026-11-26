extends GutTest

# Verifie les presets d'export (export_presets.cfg) : Windows en un seul exe, Web sans threads
# avec un canevas fixe, les tests et GUT exclus du jeu exporte.

const PRESETS_PATH := "res://export_presets.cfg"
const EXCLUDED := ["tests/*", "addons/gut/*", ".gutconfig.json"]

var _config: ConfigFile


func before_all() -> void:
	_config = ConfigFile.new()
	_config.load(PRESETS_PATH)


# Nom de la section "preset.N" du preset demande, ou "" s'il n'existe pas
func _section(preset_name: String) -> String:
	for section in _config.get_sections():
		if section.count(".") == 1 and _config.get_value(section, "name", "") == preset_name:
			return section
	return ""


func _option(preset_name: String, key: String) -> Variant:
	return _config.get_value(_section(preset_name) + ".options", key, null)


func test_le_fichier_des_presets_existe() -> void:
	assert_true(FileAccess.file_exists(PRESETS_PATH), "export_presets.cfg doit exister")


func test_il_y_a_un_preset_windows_et_un_preset_web() -> void:
	assert_ne(_section("Windows Desktop"), "", "Il faut un preset Windows Desktop")
	assert_ne(_section("Web"), "", "Il faut un preset Web")


func test_windows_donne_un_seul_exe_dans_builds() -> void:
	var section := _section("Windows Desktop")
	assert_eq(_config.get_value(section, "platform", ""), "Windows Desktop")
	assert_eq(_option("Windows Desktop", "binary_format/embed_pck"), true, "Le pck doit etre integre a l'exe")
	assert_eq(_config.get_value(section, "export_path", ""), "builds/windows/BossHide.exe")


func test_web_sans_threads_avec_un_canevas_fixe() -> void:
	var section := _section("Web")
	assert_eq(_config.get_value(section, "platform", ""), "Web")
	assert_eq(_option("Web", "variant/thread_support"), false, "Sans threads, pas besoin d'en-tetes COOP/COEP")
	assert_eq(_option("Web", "html/canvas_resize_policy"), 1, "La taille du canevas doit suivre celle du projet (1152x648)")
	assert_eq(_config.get_value(section, "export_path", ""), "builds/web/index.html")


func test_les_tests_et_gut_ne_sont_pas_exportes() -> void:
	for preset_name in ["Windows Desktop", "Web"]:
		var filter: String = _config.get_value(_section(preset_name), "exclude_filter", "")
		for pattern in EXCLUDED:
			assert_string_contains(filter, pattern, "%s doit exclure %s" % [preset_name, pattern])


func test_l_icone_du_projet_existe() -> void:
	var icon: String = ProjectSettings.get_setting("application/config/icon", "")
	assert_ne(icon, "", "Le projet doit avoir une icone")
	assert_true(ResourceLoader.exists(icon), "L'icone du projet doit exister")


func test_git_ignore_les_builds() -> void:
	var lines := FileAccess.get_file_as_string("res://.gitignore").split("\n")
	var trimmed: Array[String] = []
	for line in lines:
		trimmed.append(line.strip_edges())
	assert_has(trimmed, "/builds/", "builds/ doit etre ignore par git, sur sa propre ligne")
	assert_has(trimmed, "skills-lock.json", "skills-lock.json doit rester ignore")


func test_godot_ignore_le_dossier_des_builds() -> void:
	assert_string_contains(FileAccess.get_file_as_string("res://export.ps1"), ".gdignore", "export.ps1 doit cacher builds/ a Godot")
	for preset_name in ["Windows Desktop", "Web"]:
		var filter: String = _config.get_value(_section(preset_name), "exclude_filter", "")
		assert_string_contains(filter, "builds/*", "%s ne doit pas exporter les anciens builds" % preset_name)
