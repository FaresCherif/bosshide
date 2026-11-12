extends GutTest


func test_au_depart_le_chrono_est_a_zero_et_le_score_au_maximum() -> void:
	var score := LevelScore.new()
	assert_eq(score.elapsed(), 0.0, "Le chrono doit etre a zero au depart")
	assert_eq(score.score(), LevelScore.BASE_SCORE, "Le score doit etre au maximum au depart")


func test_update_cumule_le_temps() -> void:
	var score := LevelScore.new()
	score.update(1.5)
	score.update(2.0)
	assert_almost_eq(score.elapsed(), 3.5, 0.0001, "Le chrono doit cumuler le temps")


func test_stop_fige_le_chrono() -> void:
	var score := LevelScore.new()
	score.update(2.0)
	score.stop()
	score.update(5.0)
	assert_almost_eq(score.elapsed(), 2.0, 0.0001, "Le chrono arrete ne doit plus avancer")


func test_le_score_baisse_avec_le_temps() -> void:
	var score := LevelScore.new()
	score.update(12.34)
	assert_eq(score.score(), 877, "Le score doit perdre 10 points par seconde")


func test_le_score_ne_descend_pas_sous_zero() -> void:
	var score := LevelScore.new()
	score.update(500.0)
	assert_eq(score.score(), 0, "Le score ne doit pas etre negatif")


func test_format_du_temps_a_zero() -> void:
	assert_eq(LevelScore.format_time(0.0), "00:00.0")


func test_format_du_temps_en_secondes() -> void:
	assert_eq(LevelScore.format_time(12.34), "00:12.3")


func test_format_du_temps_en_minutes() -> void:
	assert_eq(LevelScore.format_time(75.5), "01:15.5")


func test_une_penalite_baisse_le_score() -> void:
	var score := LevelScore.new()
	score.add_penalty(LevelScore.WRONG_CODE_PENALTY)
	assert_eq(score.score(), LevelScore.BASE_SCORE - 100, "Un mauvais code doit couter 100 points")


func test_les_penalites_ne_rendent_pas_le_score_negatif() -> void:
	var score := LevelScore.new()
	score.update(95.0)
	score.add_penalty(LevelScore.WRONG_CODE_PENALTY)
	assert_eq(score.score(), 0, "Le score ne doit pas etre negatif")


func test_un_mauvais_code_est_compte_et_penalise() -> void:
	var score := LevelScore.new()
	score.add_wrong_code()
	score.add_wrong_code()
	assert_eq(score.wrong_codes(), 2, "Les mauvais codes doivent etre comptes")
	assert_eq(score.wrong_answers(), 0)
	assert_eq(score.score(), LevelScore.BASE_SCORE - 2 * LevelScore.WRONG_CODE_PENALTY)


func test_une_mauvaise_reponse_est_comptee_et_penalisee() -> void:
	var score := LevelScore.new()
	score.add_wrong_answer()
	assert_eq(score.wrong_answers(), 1, "Les mauvaises reponses doivent etre comptees")
	assert_eq(score.wrong_codes(), 0)
	assert_eq(score.score(), LevelScore.BASE_SCORE - LevelScore.WRONG_ANSWER_PENALTY)
