extends GutTest

const R := ColleagueQuiz.Result


func test_inactive_au_depart() -> void:
	assert_false(QuizReaction.new().is_active())


func test_la_reaction_dure_puis_s_arrete() -> void:
	var reaction := QuizReaction.new()
	reaction.start(R.WRONG)
	assert_true(reaction.is_active(), "La reaction doit commencer")
	assert_eq(reaction.result(), R.WRONG)
	reaction.update(QuizReaction.DURATION - 0.1)
	assert_true(reaction.is_active(), "La reaction doit durer")
	reaction.update(0.2)
	assert_false(reaction.is_active(), "La reaction doit s'arreter apres sa duree")


func test_la_bonne_reponse_choisie_est_verte() -> void:
	var style := QuizReaction.row_style(1, 1, R.RIGHT)
	assert_eq(style["color"], QuizReaction.RIGHT_COLOR)
	assert_eq(style["alpha"], 1.0)
	assert_false(style["struck"], "Une bonne reponse n'est pas barree")


func test_la_mauvaise_reponse_choisie_est_rouge_et_barree() -> void:
	var style := QuizReaction.row_style(2, 2, R.WRONG)
	assert_eq(style["color"], QuizReaction.WRONG_COLOR)
	assert_eq(style["alpha"], 1.0)
	assert_true(style["struck"], "Une mauvaise reponse est barree")


func test_les_autres_lignes_s_estompent() -> void:
	for result in [R.RIGHT, R.WRONG]:
		var style := QuizReaction.row_style(0, 2, result)
		assert_lt(style["alpha"], 0.5, "Les lignes non choisies doivent s'estomper")
		assert_false(style["struck"])
