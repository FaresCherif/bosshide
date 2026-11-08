extends GutTest

const PATHS := ["res://a.tscn", "res://b.tscn", "res://c.tscn"]


func test_au_depart_on_est_au_premier_niveau() -> void:
	var sequence := LevelSequence.new(PATHS)
	assert_eq(sequence.current_path(), PATHS[0], "Le jeu doit commencer au premier niveau")
	assert_eq(sequence.level_number(), 1, "Le premier niveau porte le numero 1")
	assert_eq(sequence.level_count(), 3, "Le nombre de niveaux doit etre connu")
	assert_false(sequence.is_last(), "Le premier niveau n'est pas le dernier")
	assert_false(sequence.is_finished(), "Le jeu ne doit pas etre fini au depart")


func test_avancer_passe_au_niveau_suivant() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.advance()
	assert_eq(sequence.current_path(), PATHS[1], "On doit passer au niveau suivant")
	assert_eq(sequence.level_number(), 2)


func test_le_dernier_niveau_est_reconnu() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.advance()
	sequence.advance()
	assert_true(sequence.is_last(), "Le troisieme niveau est le dernier")
	assert_false(sequence.is_finished(), "Le jeu n'est pas fini tant que le dernier n'est pas passe")


func test_avancer_apres_le_dernier_finit_le_jeu() -> void:
	var sequence := LevelSequence.new(PATHS)
	for i in PATHS.size():
		sequence.advance()
	assert_true(sequence.is_finished(), "Le jeu doit etre fini apres le dernier niveau")
	sequence.advance()
	assert_true(sequence.is_finished(), "Avancer encore ne doit rien casser")


func test_le_total_cumule_les_scores_des_niveaux() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(700)
	sequence.advance()
	sequence.record_score(500)
	assert_eq(sequence.total_score(), 1200, "Le total doit cumuler les niveaux")


func test_rejouer_un_niveau_remplace_son_score() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(700)
	sequence.record_score(400)
	assert_eq(sequence.total_score(), 400, "Le nouveau score doit remplacer l'ancien")


func test_recommencer_revient_au_premier_niveau_et_efface_les_scores() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(700)
	for i in PATHS.size():
		sequence.advance()
	sequence.restart_all()
	assert_eq(sequence.level_number(), 1, "On doit revenir au premier niveau")
	assert_false(sequence.is_finished(), "Le jeu doit reprendre")
	assert_eq(sequence.total_score(), 0, "Les scores doivent etre effaces")


func test_au_depart_seul_le_premier_niveau_est_debloque() -> void:
	var sequence := LevelSequence.new(PATHS)
	assert_eq(sequence.unlocked_count(), 1)
	assert_true(sequence.is_unlocked(1), "Le niveau 1 doit etre debloque")
	assert_false(sequence.is_unlocked(2), "Le niveau 2 doit etre verrouille")


func test_un_score_debloque_le_niveau_suivant() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(500)
	assert_true(sequence.is_unlocked(2), "Reussir le niveau 1 doit debloquer le 2")
	assert_false(sequence.is_unlocked(3), "Le niveau 3 doit rester verrouille")


func test_le_dernier_niveau_ne_debloque_rien_au_dela() -> void:
	var sequence := LevelSequence.new(PATHS)
	for i in PATHS.size():
		sequence.record_score(100)
		sequence.advance()
	assert_eq(sequence.unlocked_count(), PATHS.size(), "On ne peut pas debloquer plus de niveaux qu'il n'y en a")


func test_choisir_un_niveau_verrouille_est_refuse() -> void:
	var sequence := LevelSequence.new(PATHS)
	assert_false(sequence.select(2), "Un niveau verrouille ne doit pas etre choisi")
	assert_false(sequence.select(0), "Le niveau 0 n'existe pas")
	assert_false(sequence.select(4), "Le niveau 4 n'existe pas")
	assert_eq(sequence.level_number(), 1, "Le niveau courant ne doit pas changer")


func test_choisir_un_niveau_debloque_le_rend_courant() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(500)
	for i in PATHS.size():
		sequence.advance()
	assert_true(sequence.select(2), "Un niveau debloque doit pouvoir etre choisi")
	assert_eq(sequence.current_path(), PATHS[1], "Le niveau choisi doit devenir le courant")
	assert_false(sequence.is_finished(), "Choisir un niveau doit reprendre le jeu")


func test_recommencer_garde_les_niveaux_debloques() -> void:
	var sequence := LevelSequence.new(PATHS)
	sequence.record_score(500)
	sequence.restart_all()
	assert_true(sequence.is_unlocked(2), "Les deblocages doivent durer toute la session")
