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


func _pause(game: Node) -> void:
	_level(game).pause_requested.emit()


func test_les_signaux_de_la_pause_sont_connectes() -> void:
	var game := _add_game_playing()
	assert_true(_level(game).pause_requested.is_connected(game._on_level_pause_requested), "Echap en jeu doit prevenir le jeu")
	assert_true(_button(game, "Pause/Boutons/Reprendre").pressed.is_connected(game._on_reprendre_pressed))
	assert_true(_button(game, "Pause/Boutons/Selection").pressed.is_connected(game._on_selection_pressed))
	assert_true(_button(game, "Pause/Boutons/Menu").pressed.is_connected(game._on_menu_pressed))


func test_la_pause_est_cachee_au_depart() -> void:
	var game := _add_game_playing()
	assert_false(_screen(game, "Pause").visible, "Le menu de pause doit etre cache en jeu")


func test_la_pause_fige_le_niveau_sans_le_decharger() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	_pause(game)

	assert_true(_screen(game, "Pause").visible, "Le menu de pause doit s'afficher")
	assert_eq(_level(game), level, "Le niveau doit rester charge")
	assert_eq(level.process_mode, Node.PROCESS_MODE_DISABLED, "Le niveau doit etre fige")


func test_le_chrono_ne_bouge_pas_pendant_la_pause() -> void:
	var game := _add_game_playing()
	await wait_physics_frames(5)
	_pause(game)
	var chrono: Label = _level(game).get_node("Interface/Chrono")
	var text := chrono.text

	await wait_physics_frames(10)

	assert_eq(chrono.text, text, "Le chrono doit etre fige pendant la pause")


func test_resume_reprend_le_meme_niveau_au_meme_endroit() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	level.get_node("Player").position.x = -1000.0
	_pause(game)

	_button(game, "Pause/Boutons/Reprendre").pressed.emit()

	assert_false(_screen(game, "Pause").visible, "Le menu de pause doit se cacher")
	assert_eq(_level(game), level, "Le meme niveau doit reprendre")
	assert_eq(level.process_mode, Node.PROCESS_MODE_INHERIT, "Le niveau doit etre reactive")
	assert_eq(level.get_node("Player").position.x, -1000.0, "Le joueur doit etre au meme endroit")


func test_echap_dans_la_pause_reprend_le_niveau() -> void:
	var game := _add_game_playing()
	var level := _level(game)
	_pause(game)

	game._unhandled_input(_pressed("ui_cancel"))

	assert_false(_screen(game, "Pause").visible, "Echap doit fermer la pause")
	assert_eq(level.process_mode, Node.PROCESS_MODE_INHERIT, "Le niveau doit etre reactive")


func test_level_select_depuis_la_pause_abandonne_le_niveau() -> void:
	var game := _add_game_playing()
	_pause(game)
	_button(game, "Pause/Boutons/Selection").pressed.emit()
	assert_true(_screen(game, "Selecteur").visible, "Le selecteur doit s'ouvrir")
	assert_false(_screen(game, "Pause").visible, "La pause doit se cacher")
	assert_null(_level(game), "Le niveau doit etre abandonne")


func test_main_menu_depuis_la_pause_abandonne_le_niveau() -> void:
	var game := _add_game_playing()
	_pause(game)
	_button(game, "Pause/Boutons/Menu").pressed.emit()
	assert_true(_screen(game, "MenuPrincipal").visible, "Le menu principal doit s'ouvrir")
	assert_null(_level(game), "Le niveau doit etre abandonne")


func _press_escape() -> void:
	var event := InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	Input.parse_input_event(event)
	var release := InputEventAction.new()
	release.action = "ui_cancel"
	release.pressed = false
	Input.parse_input_event(release)
	# En headless, les evenements restent en tampon tant que rien ne les vide
	Input.flush_buffered_events()


func test_un_vrai_appui_sur_echap_ouvre_la_pause_sans_la_refermer() -> void:
	var game := _add_game_playing()
	await wait_frames(2)

	_press_escape()
	await wait_frames(2)

	assert_true(_screen(game, "Pause").visible, "Un seul appui doit laisser la pause ouverte")
	assert_eq(_level(game).process_mode, Node.PROCESS_MODE_DISABLED, "Le niveau doit rester fige")


func test_l_ecran_de_reussite_connait_le_numero_du_niveau() -> void:
	var game := _add_game_playing()
	var screen: Control = _level(game).get_node("Interface/MessageSucces")
	assert_string_contains(screen.get_node("Titre").text, "Level 1 complete!")
	assert_eq(screen.get_node("Boutons/Suivant").text, "Next mission", "Le niveau 1 n'est pas le dernier")


func test_le_dernier_niveau_propose_finish() -> void:
	var game := _add_game_playing()
	for i in Game.LEVELS.size() - 1:
		_level(game).succeeded.emit(500)
		_level(game).next_requested.emit()
	assert_eq(_level(game).get_node("Interface/MessageSucces/Boutons/Suivant").text, "Clock out")


func test_la_premiere_reussite_affiche_un_record() -> void:
	var game := _add_game_playing()
	_level(game).succeeded.emit(700)
	var record: Label = _level(game).get_node("Interface/MessageSucces/Record")
	assert_true(record.visible, "Le meilleur score doit s'afficher")
	assert_eq(record.text, "New best! Best: 700")


func test_un_score_plus_faible_n_affiche_pas_de_record() -> void:
	var game := _add_game_playing()
	_level(game).succeeded.emit(700)
	_level(game).restart_requested.emit()
	_level(game).succeeded.emit(400)
	var record: Label = _level(game).get_node("Interface/MessageSucces/Record")
	assert_eq(record.text, "Best: 700", "Le record de la session doit rester affiche sans New best")


# En headless la fenetre est minuscule : on place la scene dans un viewport a la taille du jeu
func _screen_size() -> Vector2i:
	return Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))


func _add_in_game_viewport(node: Node) -> Node:
	var viewport: SubViewport = add_child_autofree(SubViewport.new())
	viewport.size = _screen_size()
	viewport.add_child(node)
	return node


func _assert_inside_screen(screen: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(_screen_size()))
	for node in screen.find_children("*", "Control", true, false):
		var control := node as Control
		if control.is_visible_in_tree():
			assert_true(bounds.encloses(control.get_global_rect()), "%s doit rester dans l'ecran : %s" % [control.name, control.get_global_rect()])


func test_le_menu_a_un_slogan_et_des_boutons_a_theme() -> void:
	var game := _add_game()
	assert_eq(game.get_node("Interface/MenuPrincipal/Slogan").text, "Productivity is a state of mind. Yours is in the toilets.")
	assert_eq(_button(game, "MenuPrincipal/Boutons/Jouer").text, "Clock in")
	assert_eq(_button(game, "MenuPrincipal/Boutons/Choisir").text, "Pick a mission")
	assert_eq(_button(game, "MenuPrincipal/Boutons/Quitter").text, "Resign")


func test_le_selecteur_a_des_textes_a_theme() -> void:
	var game := _add_game()
	_open_selector(game)
	assert_eq(game.get_node("Interface/Selecteur/Titre").text, "Today's missions")
	assert_eq(_button(game, "Selecteur/Retour").text, "Back to lobby")
	assert_string_contains(_level_button(game, 2).text, "locked by HR")


func test_la_pause_est_une_pause_cafe() -> void:
	var game := _add_game()
	assert_eq(game.get_node("Interface/Pause/Titre").text, "Coffee break")
	assert_eq(_button(game, "Pause/Boutons/Reprendre").text, "Back to work")
	assert_eq(_button(game, "Pause/Boutons/Selection").text, "Change mission")
	assert_eq(_button(game, "Pause/Boutons/Menu").text, "Go home early")


func test_l_ecran_final_est_un_bilan_annuel() -> void:
	var game := _add_game_playing()
	_finish_all_levels(game, 300)
	var text: String = game.get_node("Interface/FinDuJeu").text
	assert_string_contains(text, "Annual review: %d points." % (300 * Game.LEVELS.size()))
	assert_string_contains(text, "Your reward: more work.")


func test_le_fond_moquette_cache_le_vide_hors_des_niveaux() -> void:
	var game := _add_game()
	var background: Control = game.get_node("Interface/Fond")
	assert_true(background.visible, "Le menu doit avoir un fond")
	_open_selector(game)
	assert_true(background.visible, "Le selecteur doit avoir un fond")
	_level_button(game, 1).pressed.emit()
	assert_false(background.visible, "Le fond ne doit pas cacher le niveau")


func test_le_numero_de_niveau_reste_lisible_sur_le_decor() -> void:
	var game := _add_game()
	assert_eq(game.get_node("Interface/Niveau").theme_type_variation, &"HudLabel")


func test_les_menus_tiennent_dans_l_ecran() -> void:
	var scene: PackedScene = load(GAME_SCENE_PATH)
	var game: Node = _add_in_game_viewport(scene.instantiate())
	await wait_frames(2)
	_assert_inside_screen(_screen(game, "MenuPrincipal"))
	_open_selector(game)
	await wait_frames(2)
	_assert_inside_screen(_screen(game, "Selecteur"))
	_level_button(game, 1).pressed.emit()
	_pause(game)
	await wait_frames(2)
	_assert_inside_screen(_screen(game, "Pause"))
