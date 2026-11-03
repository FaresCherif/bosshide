extends GutTest


func test_au_depart_le_niveau_n_est_pas_termine() -> void:
	var progress := LevelProgress.new()
	assert_false(progress.is_finished(), "Le niveau ne doit pas etre termine au depart")


func test_au_depart_le_joueur_peut_bouger() -> void:
	var progress := LevelProgress.new()
	assert_true(progress.can_move(), "Le joueur doit pouvoir bouger au depart")


func test_au_depart_la_relance_est_refusee() -> void:
	var progress := LevelProgress.new()
	assert_false(progress.can_restart(), "La relance doit etre refusee avant l'arrivee")


func test_atteindre_l_arrivee_termine_le_niveau() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	assert_true(progress.is_finished(), "Le niveau doit etre termine a l'arrivee")


func test_apres_l_arrivee_le_joueur_ne_peut_plus_bouger() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	assert_false(progress.can_move(), "Le joueur doit etre fige apres l'arrivee")


func test_apres_l_arrivee_la_relance_est_autorisee() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	assert_true(progress.can_restart(), "La relance doit etre autorisee apres l'arrivee")


func test_atteindre_deux_fois_l_arrivee_ne_change_rien() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	progress.reach_goal()
	assert_true(progress.is_finished(), "Le niveau doit rester termine")
	assert_false(progress.can_move(), "Le joueur doit rester fige")
	assert_true(progress.can_restart(), "La relance doit rester autorisee")
