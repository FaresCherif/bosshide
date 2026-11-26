extends GutTest

# Verifie le deploiement sur itch.io : la version du projet (comparee au tag par la CI)
# et le workflow GitHub Actions qui teste, exporte puis pousse les deux canaux.

const WORKFLOW_PATH := "res://.github/workflows/itch.yml"
const PRESETS_PATH := "res://export_presets.cfg"

var _workflow := ""


func before_all() -> void:
	_workflow = FileAccess.get_file_as_string(WORKFLOW_PATH)


# Dossier ou un preset d'export ecrit ses fichiers (export_path sans le nom du fichier)
func _export_dir(preset_name: String) -> String:
	var config := ConfigFile.new()
	config.load(PRESETS_PATH)
	for section in config.get_sections():
		if section.count(".") == 1 and config.get_value(section, "name", "") == preset_name:
			return String(config.get_value(section, "export_path", "")).get_base_dir()
	return ""


func test_la_version_du_projet_a_la_forme_x_y_z() -> void:
	var version: String = ProjectSettings.get_setting("application/config/version", "")
	var regex := RegEx.create_from_string("^\\d+\\.\\d+\\.\\d+$")
	assert_not_null(regex.search(version), "config/version doit avoir la forme x.y.z, pas '%s'" % version)


func test_le_workflow_existe() -> void:
	assert_true(FileAccess.file_exists(WORKFLOW_PATH), "Le workflow itch.yml doit exister")


func test_le_workflow_se_declenche_sur_les_tags_de_version() -> void:
	assert_string_contains(_workflow, "tags:")
	assert_string_contains(_workflow, "\"v*\"", "Un tag v* doit lancer le deploiement")
	assert_string_contains(_workflow, "workflow_dispatch", "Le deploiement doit aussi pouvoir se lancer a la main")


func test_le_workflow_teste_avant_d_exporter() -> void:
	var tests := _workflow.find("run_tests.ps1")
	var export := _workflow.find("export.ps1")
	assert_gt(tests, -1, "Le workflow doit lancer les tests")
	assert_gt(export, tests, "Les tests doivent passer avant l'export")


func test_le_workflow_pousse_les_dossiers_exportes_sur_les_deux_canaux() -> void:
	var windows_dir := _export_dir("Windows Desktop")
	var web_dir := _export_dir("Web")
	assert_string_contains(_workflow, "butler push %s" % windows_dir)
	assert_string_contains(_workflow, ":windows", "Le build Windows va sur le canal windows")
	assert_string_contains(_workflow, "butler push %s" % web_dir)
	assert_string_contains(_workflow, ":html5", "Le build Web va sur le canal html5")
	assert_gt(_workflow.find(":html5"), _workflow.find("export.ps1"), "On ne pousse qu'apres l'export")


func test_le_run_joint_les_dossiers_exportes_sans_zip() -> void:
	assert_string_contains(_workflow, "path: %s" % _export_dir("Windows Desktop"), "Le build Windows doit etre joint au run")
	assert_string_contains(_workflow, "path: %s" % _export_dir("Web"), "Le build Web doit etre joint au run")
	assert_does_not_have(_workflow, "builds/*.zip", "Les zips ne sont plus crees")
	assert_false(FileAccess.get_file_as_string("res://export.ps1").contains("Compress-Archive"), "export.ps1 ne doit plus creer de zip")
