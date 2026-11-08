extends GutTest


func test_il_y_a_assez_de_questions() -> void:
	assert_gte(QuizQuestions.QUESTIONS.size(), 5, "Il faut au moins 5 questions")


func test_chaque_question_est_complete() -> void:
	for question: Dictionary in QuizQuestions.QUESTIONS:
		assert_false(String(question["text"]).is_empty(), "La question doit avoir un texte")
		assert_eq(question["choices"].size(), 3, "La question doit avoir 3 choix : %s" % question["text"])
		for choice in question["choices"]:
			assert_false(String(choice).is_empty(), "Un choix ne doit pas etre vide : %s" % question["text"])
		assert_between(int(question["answer"]), 0, 2, "La reponse doit etre un des 3 choix : %s" % question["text"])


func test_les_bonnes_reponses_ne_sont_pas_toujours_a_la_meme_place() -> void:
	var positions := {}
	for question: Dictionary in QuizQuestions.QUESTIONS:
		positions[question["answer"]] = true
	assert_eq(positions.size(), 3, "Les bonnes reponses doivent etre a des places variees")
