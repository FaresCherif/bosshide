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


func test_au_depart_il_n_y_a_pas_de_game_over() -> void:
	var progress := LevelProgress.new()
	assert_false(progress.is_game_over(), "Il ne doit pas y avoir de game over au depart")


func test_le_game_over_termine_le_niveau() -> void:
	var progress := LevelProgress.new()
	progress.fail()
	assert_true(progress.is_game_over(), "Le game over doit etre enregistre")
	assert_true(progress.is_finished(), "Le niveau doit etre termine apres un game over")


func test_apres_le_game_over_le_joueur_ne_peut_plus_bouger() -> void:
	var progress := LevelProgress.new()
	progress.fail()
	assert_false(progress.can_move(), "Le joueur doit etre fige apres un game over")


func test_apres_le_game_over_la_relance_est_autorisee() -> void:
	var progress := LevelProgress.new()
	progress.fail()
	assert_true(progress.can_restart(), "La relance doit etre autorisee apres un game over")


func test_atteindre_l_arrivee_n_est_pas_un_game_over() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	assert_false(progress.is_game_over(), "La victoire ne doit pas etre un game over")


func test_un_game_over_apres_la_victoire_ne_change_rien() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	progress.fail()
	assert_false(progress.is_game_over(), "La victoire doit rester acquise")


func test_atteindre_l_arrivee_apres_un_game_over_ne_change_rien() -> void:
	var progress := LevelProgress.new()
	progress.fail()
	progress.reach_goal()
	assert_true(progress.is_game_over(), "Le game over doit rester acquis")


func test_au_depart_on_ne_peut_pas_continuer() -> void:
	assert_false(LevelProgress.new().can_continue(), "On ne passe pas au niveau suivant avant l'arrivee")


func test_apres_une_reussite_on_peut_continuer() -> void:
	var progress := LevelProgress.new()
	progress.reach_goal()
	assert_true(progress.can_continue(), "Une reussite doit permettre de continuer")


func test_apres_un_echec_on_ne_peut_pas_continuer() -> void:
	var progress := LevelProgress.new()
	progress.fail()
	progress.reach_goal()
	assert_false(progress.can_continue(), "Un echec ne doit pas permettre de continuer")
