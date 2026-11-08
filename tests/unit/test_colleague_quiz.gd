extends GutTest

const QUESTION := {"text": "What does ASAP mean?", "choices": ["A", "B", "C"], "answer": 1}


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func _talking_quiz() -> ColleagueQuiz:
	var quiz := ColleagueQuiz.new(QUESTION)
	quiz.start()
	return quiz


func test_au_depart_le_collegue_ne_parle_pas() -> void:
	var quiz := ColleagueQuiz.new(QUESTION)
	assert_false(quiz.is_talking(), "Le collegue ne doit pas parler au depart")
	assert_false(quiz.is_done(), "La conversation ne doit pas etre finie au depart")
	assert_eq(quiz.question(), QUESTION)


func test_la_conversation_ne_demarre_qu_une_fois() -> void:
	var quiz := ColleagueQuiz.new(QUESTION)
	assert_true(quiz.start(), "La conversation doit demarrer")
	assert_true(quiz.is_talking(), "Le collegue doit parler")
	assert_false(quiz.start(), "Elle ne doit pas redemarrer pendant qu'il parle")
	quiz.answer(1)
	assert_false(quiz.start(), "Elle ne doit pas redemarrer apres la reponse")
	assert_false(quiz.is_talking(), "Le collegue ne doit plus parler")


func test_la_bonne_reponse_termine_la_conversation() -> void:
	var quiz := _talking_quiz()
	assert_eq(quiz.answer(1), ColleagueQuiz.Result.RIGHT, "La reponse doit etre juste")
	assert_false(quiz.is_talking(), "La conversation doit etre finie")
	assert_true(quiz.is_done(), "La conversation doit etre finie")


func test_une_mauvaise_reponse_termine_la_conversation() -> void:
	var quiz := _talking_quiz()
	assert_eq(quiz.answer(2), ColleagueQuiz.Result.WRONG, "La reponse doit etre fausse")
	assert_false(quiz.is_talking(), "La conversation doit etre finie")
	assert_true(quiz.is_done(), "La conversation doit etre finie")


func test_un_choix_hors_limites_est_ignore() -> void:
	var quiz := _talking_quiz()
	assert_eq(quiz.answer(3), ColleagueQuiz.Result.IGNORED, "Le choix 4 n'existe pas")
	assert_eq(quiz.answer(-1), ColleagueQuiz.Result.IGNORED, "Un choix negatif n'existe pas")
	assert_true(quiz.is_talking(), "Le collegue doit toujours parler")


func test_repondre_hors_conversation_est_ignore() -> void:
	var quiz := ColleagueQuiz.new(QUESTION)
	assert_eq(quiz.answer(1), ColleagueQuiz.Result.IGNORED, "Sans conversation, pas de reponse")
	assert_false(quiz.is_done(), "La conversation ne doit pas etre consideree comme finie")


func test_le_choix_de_la_question_depend_de_la_graine() -> void:
	var questions := QuizQuestions.QUESTIONS
	var first := ColleagueQuiz.pick_question(questions, _rng(3))
	assert_eq(ColleagueQuiz.pick_question(questions, _rng(3)), first, "Meme graine, meme question")
	assert_has(questions, first, "La question doit venir de la liste")
