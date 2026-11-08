extends GutTest

const GAME_SCENE_PATH := "res://Game.tscn"


func _add_game() -> Node:
	var scene: PackedScene = load(GAME_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


# Appuie sur Play : le jeu demarre sur le menu, sans niveau charge
func _add_game_playing() -> Node:
	var game := _add_game()
	_button(game, "MenuPrincipal/Boutons/Jouer").pressed.emit()
	return game


func _button(game: Node, path: String) -> Button:
	return game.get_node("Interface/" + path)


func _pressed(action: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


func _level(game: Node) -> Node:
	return game.get_node_or_null("Niveau")


func test_play_lance_le_premier_niveau() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	assert_not_null(level, "Le jeu doit charger un niveau")
	assert_eq(level.scene_file_path, Game.LEVELS[0], "Le jeu doit commencer au niveau 1")
	assert_eq(game.get_node("Interface/Niveau").text, "Level 1/%d" % Game.LEVELS.size())
	assert_false(game.get_node("Interface/FinDuJeu").visible, "L'ecran de fin doit etre cache")


func test_les_signaux_du_niveau_sont_connectes() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	assert_true(level.succeeded.is_connected(game._on_level_succeeded), "La reussite doit prevenir le jeu")
	assert_true(level.restart_requested.is_connected(game._on_level_restart_requested), "La relance doit prevenir le jeu")
	assert_true(level.next_requested.is_connected(game._on_level_next_requested), "Le niveau suivant doit prevenir le jeu")


func test_le_niveau_suivant_est_charge() -> void:
	var game := _add_game_playing()
	_level(game).next_requested.emit()
	var level := _level(game)
	assert_eq(level.scene_file_path, Game.LEVELS[1], "Le niveau 2 doit etre charge")
	assert_eq(game.get_node("Interface/Niveau").text, "Level 2/%d" % Game.LEVELS.size())
	assert_true(level.next_requested.is_connected(game._on_level_next_requested), "Le nouveau niveau doit etre connecte")


func test_relancer_recharge_le_meme_niveau() -> void:
	var game := _add_game_playing()
	var old_level := _level(game)
	old_level.restart_requested.emit()
	var level := _level(game)
	assert_ne(level, old_level, "Un nouveau niveau doit etre instancie")
	assert_eq(level.scene_file_path, Game.LEVELS[0], "Le meme niveau doit etre recharge")


func _finish_all_levels(game: Node, score: int) -> void:
	for i in Game.LEVELS.size():
		var level := _level(game)
		level.succeeded.emit(score)
		level.next_requested.emit()


func test_apres_le_dernier_niveau_l_ecran_de_fin_affiche_le_total() -> void:
	var game := _add_game_playing()
	_finish_all_levels(game, 300)

	var end_screen: Label = game.get_node("Interface/FinDuJeu")
	assert_true(end_screen.visible, "L'ecran de fin doit s'afficher")
	assert_string_contains(end_screen.text, str(300 * Game.LEVELS.size()), "Le total doit s'afficher")
	assert_null(_level(game), "Aucun niveau ne doit rester charge")


func test_r_sur_l_ecran_de_fin_revient_au_premier_niveau() -> void:
	var game := _add_game_playing()
	_finish_all_levels(game, 300)

	game._unhandled_input(_pressed("restart"))

	assert_false(game.get_node("Interface/FinDuJeu").visible, "L'ecran de fin doit se cacher")
	assert_eq(_level(game).scene_file_path, Game.LEVELS[0], "Le jeu doit reprendre au niveau 1")


func test_r_pendant_le_jeu_n_est_pas_gere_par_le_jeu() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	game._unhandled_input(_pressed("restart"))
	assert_eq(_level(game), level, "Pendant un niveau, R est gere par le niveau")


func _screen(game: Node, screen_name: String) -> Control:
	return game.get_node("Interface/" + screen_name)


func _level_button(game: Node, number: int) -> Button:
	return game.get_node("Interface/Selecteur/Niveaux").get_child(number - 1)


func _open_selector(game: Node) -> void:
	_button(game, "MenuPrincipal/Boutons/Choisir").pressed.emit()


func test_au_lancement_le_menu_est_affiche() -> void:
	var game := _add_game()
	await wait_frames(1)
	assert_true(_screen(game, "MenuPrincipal").visible, "Le menu doit s'afficher au lancement")
	assert_false(_screen(game, "Selecteur").visible, "Le selecteur doit etre cache")
	assert_false(game.get_node("Interface/Niveau").visible, "Le numero de niveau doit etre cache")
	assert_null(_level(game), "Aucun niveau ne doit etre charge")
	assert_eq(game.get_viewport().gui_get_focus_owner(), _button(game, "MenuPrincipal/Boutons/Jouer"), "Play doit avoir le focus")
	assert_eq(game.get_node("Interface/MenuPrincipal/Titre").text, "BossHide")


func test_les_signaux_des_boutons_sont_connectes() -> void:
	var game := _add_game()
	assert_true(_button(game, "MenuPrincipal/Boutons/Jouer").pressed.is_connected(game._on_jouer_pressed))
	assert_true(_button(game, "MenuPrincipal/Boutons/Choisir").pressed.is_connected(game._on_choisir_pressed))
	assert_true(_button(game, "MenuPrincipal/Boutons/Quitter").pressed.is_connected(game._on_quitter_pressed))
	assert_true(_button(game, "Selecteur/Retour").pressed.is_connected(game._on_retour_pressed))


func test_le_signal_menu_du_niveau_est_connecte() -> void:
	var game := _add_game_playing()
	assert_true(_level(game).menu_requested.is_connected(game._on_level_menu_requested), "Echap dans le niveau doit prevenir le jeu")


func test_play_cache_le_menu() -> void:
	var game := _add_game_playing()
	assert_false(_screen(game, "MenuPrincipal").visible, "Le menu doit se cacher en jeu")
	assert_true(game.get_node("Interface/Niveau").visible, "Le numero de niveau doit s'afficher en jeu")


func test_le_selecteur_propose_seulement_le_niveau_1_au_depart() -> void:
	var game := _add_game()
	_open_selector(game)

	assert_true(_screen(game, "Selecteur").visible, "Le selecteur doit s'ouvrir")
	assert_false(_screen(game, "MenuPrincipal").visible, "Le menu doit se cacher")
	assert_eq(game.get_node("Interface/Selecteur/Niveaux").get_child_count(), Game.LEVELS.size(), "Un bouton par niveau")
	assert_false(_level_button(game, 1).disabled, "Le niveau 1 doit etre jouable")
	assert_eq(_level_button(game, 1).text, "Level 1")
	assert_true(_level_button(game, 2).disabled, "Le niveau 2 doit etre verrouille")
	assert_string_contains(_level_button(game, 2).text, "locked")


func test_back_revient_au_menu() -> void:
	var game := _add_game()
	_open_selector(game)
	_button(game, "Selecteur/Retour").pressed.emit()
	assert_true(_screen(game, "MenuPrincipal").visible, "Back doit revenir au menu")
	assert_false(_screen(game, "Selecteur").visible, "Le selecteur doit se cacher")


func test_echap_dans_le_selecteur_revient_au_menu() -> void:
	var game := _add_game()
	_open_selector(game)
	game._unhandled_input(_pressed("ui_cancel"))
	assert_true(_screen(game, "MenuPrincipal").visible, "Echap doit revenir au menu")


func test_un_bouton_de_niveau_charge_ce_niveau() -> void:
	var game := _add_game()
	_open_selector(game)
	_level_button(game, 1).pressed.emit()
	assert_eq(_level(game).scene_file_path, Game.LEVELS[0], "Le niveau choisi doit etre charge")
	assert_false(_screen(game, "Selecteur").visible, "Le selecteur doit se cacher en jeu")


func test_echap_dans_un_niveau_ramene_au_selecteur() -> void:
	var game := _add_game_playing()
	_level(game).menu_requested.emit()
	assert_null(_level(game), "Le niveau doit etre decharge")
	assert_true(_screen(game, "Selecteur").visible, "Le selecteur doit s'ouvrir")
	assert_false(game.get_node("Interface/Niveau").visible, "Le numero de niveau doit se cacher")


func test_reussir_le_niveau_1_debloque_le_niveau_2() -> void:
	var game := _add_game_playing()
	_level(game).succeeded.emit(500)
	_level(game).menu_requested.emit()

	assert_false(_level_button(game, 2).disabled, "Le niveau 2 doit etre debloque")
	assert_eq(_level_button(game, 2).text, "Level 2")
	_level_button(game, 2).pressed.emit()
	assert_eq(_level(game).scene_file_path, Game.LEVELS[1], "Le niveau 2 doit etre charge")


func test_echap_sur_l_ecran_de_fin_ouvre_le_selecteur() -> void:
	var game := _add_game_playing()
	_finish_all_levels(game, 300)

	game._unhandled_input(_pressed("ui_cancel"))

	assert_false(game.get_node("Interface/FinDuJeu").visible, "L'ecran de fin doit se cacher")
	assert_true(_screen(game, "Selecteur").visible, "Le selecteur doit s'ouvrir")


func test_l_ecran_de_fin_mentionne_echap() -> void:
	var game := _add_game_playing()
	_finish_all_levels(game, 300)
	assert_string_contains(game.get_node("Interface/FinDuJeu").text, "Esc")


func test_le_selecteur_affiche_le_meilleur_score_des_niveaux_reussis() -> void:
	var game := _add_game_playing()
	_level(game).succeeded.emit(500)
	_level(game).menu_requested.emit()

	var text := _level_button(game, 1).text
	assert_string_contains(text, "Level 1")
	assert_string_contains(text, "Best: 500", "Le meilleur score doit s'afficher")
	assert_false(_level_button(game, 2).text.contains("Best"), "Un niveau pas encore reussi n'a pas de score")


func test_un_moins_bon_score_ne_change_pas_l_affichage() -> void:
	var game := _add_game_playing()
	_level(game).succeeded.emit(500)
	_level(game).restart_requested.emit()
	_level(game).succeeded.emit(300)
	_level(game).menu_requested.emit()

	assert_string_contains(_level_button(game, 1).text, "Best: 500", "Le meilleur score doit rester affiche")
