extends GutTest


func test_au_depart_le_joueur_ne_travaille_pas() -> void:
	var work := PlayerWork.new()
	assert_false(work.is_working(), "Le joueur ne doit pas travailler au depart")


func test_appuyer_sur_un_bureau_fait_travailler() -> void:
	var work := PlayerWork.new()
	work.press_work(true)
	assert_true(work.is_working(), "Le joueur doit travailler sur un bureau")


func test_appuyer_hors_bureau_ne_fait_rien() -> void:
	var work := PlayerWork.new()
	work.press_work(false)
	assert_false(work.is_working(), "Le joueur ne doit pas travailler hors d'un bureau")


func test_appuyer_pendant_le_travail_arrete_le_travail() -> void:
	var work := PlayerWork.new()
	work.press_work(true)
	work.press_work(true)
	assert_false(work.is_working(), "Un second appui doit arreter le travail")


func test_appuyer_hors_bureau_pendant_le_travail_arrete_le_travail() -> void:
	var work := PlayerWork.new()
	work.press_work(true)
	work.press_work(false)
	assert_false(work.is_working(), "Le second appui doit marcher meme hors d'un bureau")


func test_stop_arrete_le_travail() -> void:
	var work := PlayerWork.new()
	work.press_work(true)
	work.stop()
	assert_false(work.is_working(), "Stop doit arreter le travail")


func test_stop_sans_travail_ne_change_rien() -> void:
	var work := PlayerWork.new()
	work.stop()
	assert_false(work.is_working(), "Stop ne doit pas faire travailler le joueur")


func test_la_direction_est_conservee_hors_du_travail() -> void:
	var work := PlayerWork.new()
	assert_eq(work.allowed_direction(-1.0), -1.0, "Le joueur doit pouvoir bouger hors du travail")


func test_la_direction_est_nulle_pendant_le_travail() -> void:
	var work := PlayerWork.new()
	work.press_work(true)
	assert_eq(work.allowed_direction(1.0), 0.0, "Le joueur doit etre immobile pendant le travail")
