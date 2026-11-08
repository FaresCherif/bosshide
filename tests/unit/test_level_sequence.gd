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
