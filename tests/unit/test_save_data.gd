extends GutTest

const PATHS := ["res://a.tscn", "res://b.tscn", "res://c.tscn"]
const FILE := "user://test_save_data.cfg"


func before_each() -> void:
	SaveData.erase(FILE)


func after_all() -> void:
	SaveData.erase(FILE)


func _write_raw(text: String) -> void:
	var file := FileAccess.open(FILE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _loaded() -> Array:
	var sequence := LevelSequence.new(PATHS)
	var profile := EmployeeProfile.new()
	SaveData.load_into(sequence, profile, FILE)
	return [sequence, profile]


func test_les_tests_n_utilisent_pas_la_vraie_sauvegarde() -> void:
	assert_ne(SaveData.path, SaveData.DEFAULT_PATH, "Le hook GUT doit detourner le chemin de sauvegarde")


func test_aller_retour_complet() -> void:
	var sequence := LevelSequence.new(PATHS)
	var profile := EmployeeProfile.new()
	sequence.record_score(780)
	sequence.advance()
	sequence.record_score(640)
	profile.select("mug")
	assert_eq(SaveData.save(sequence, profile, FILE), OK, "L'ecriture doit reussir")
	var loaded := _loaded()
	assert_eq(loaded[0].unlocked_count(), 3, "Les deblocages doivent etre relus")
	assert_eq(loaded[0].best_score(1), 780, "Le meilleur score du niveau 1 doit etre relu")
	assert_eq(loaded[0].best_score(2), 640, "Le meilleur score du niveau 2 doit etre relu")
	assert_false(loaded[0].has_best_score(3), "Le niveau 3 n'a pas de meilleur score")
	assert_eq(loaded[1].icon_id(), "mug", "L'icone doit etre relue")


func test_les_scores_de_la_partie_ne_sont_pas_sauves() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(500)
	SaveData.save(sequence, EmployeeProfile.new(), FILE)
	assert_eq(_loaded()[0].total_score(), 0, "Le total de la partie ne doit pas etre sauve")


func test_sans_fichier_les_valeurs_par_defaut() -> void:
	var loaded := _loaded()
	assert_eq(loaded[0].unlocked_count(), 1, "Seul le niveau 1 doit etre debloque")
	assert_false(loaded[0].has_best_score(1), "Aucun meilleur score")
	assert_eq(loaded[1].icon_id(), EmployeeProfile.DEFAULT_ICON, "L'icone par defaut")


func test_un_fichier_illisible_donne_les_valeurs_par_defaut() -> void:
	_write_raw("ceci n'est pas [un fichier = de sauvegarde\n{{{")
	var loaded := _loaded()
	assert_eq(loaded[0].unlocked_count(), 1, "Seul le niveau 1 doit etre debloque")
	assert_eq(loaded[1].icon_id(), EmployeeProfile.DEFAULT_ICON, "L'icone par defaut")


func test_les_valeurs_fausses_sont_ignorees_une_a_une() -> void:
	_write_raw("[progress]\nunlocked=\"abc\"\nbest_scores={1: 700, 42: 900, 2: -5, \"x\": 3}\n[profile]\nicon=\"unicorn\"\n")
	var loaded := _loaded()
	assert_eq(loaded[0].best_score(1), 700, "Le score valide du niveau 1 doit etre garde")
	assert_false(loaded[0].has_best_score(2), "Un score negatif doit etre ignore")
	assert_eq(loaded[0].unlocked_count(), 2, "Le niveau 1 reussi debloque le niveau 2 malgre un nombre invalide")
	assert_eq(loaded[1].icon_id(), EmployeeProfile.DEFAULT_ICON, "Une icone inconnue doit etre ignoree")


func test_un_nombre_de_niveaux_debloques_hors_bornes_est_borne() -> void:
	_write_raw("[progress]\nunlocked=99\n")
	assert_eq(_loaded()[0].unlocked_count(), PATHS.size(), "Pas plus de niveaux que le jeu n'en a")
	_write_raw("[progress]\nunlocked=-3\n")
	assert_eq(_loaded()[0].unlocked_count(), 1, "Au moins le niveau 1")


func test_effacer_supprime_le_fichier() -> void:
	SaveData.save(LevelSequence.new(PATHS), EmployeeProfile.new(), FILE)
	assert_true(FileAccess.file_exists(FILE), "Le fichier doit exister apres une sauvegarde")
	SaveData.erase(FILE)
	assert_false(FileAccess.file_exists(FILE), "Le fichier doit etre supprime")
