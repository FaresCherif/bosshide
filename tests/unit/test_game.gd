extends GutTest

const GAME_SCENE_PATH := "res://Game.tscn"


func _add_game() -> Node:
	var scene: PackedScene = load(GAME_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func _pressed(action: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


func _level(game: Node) -> Node:
	return game.get_node_or_null("Niveau")


func test_le_jeu_demarre_au_premier_niveau() -> void:
	var game := _add_game()
	var level := _level(game)
	assert_not_null(level, "Le jeu doit charger un niveau")
	assert_eq(level.scene_file_path, Game.LEVELS[0], "Le jeu doit commencer au niveau 1")
	assert_eq(game.get_node("Interface/Niveau").text, "Level 1/%d" % Game.LEVELS.size())
	assert_false(game.get_node("Interface/FinDuJeu").visible, "L'ecran de fin doit etre cache")


func test_les_signaux_du_niveau_sont_connectes() -> void:
	var game := _add_game()
	var level := _level(game)
	assert_true(level.succeeded.is_connected(game._on_level_succeeded), "La reussite doit prevenir le jeu")
	assert_true(level.restart_requested.is_connected(game._on_level_restart_requested), "La relance doit prevenir le jeu")
	assert_true(level.next_requested.is_connected(game._on_level_next_requested), "Le niveau suivant doit prevenir le jeu")


func test_le_niveau_suivant_est_charge() -> void:
	var game := _add_game()
	_level(game).next_requested.emit()
	var level := _level(game)
	assert_eq(level.scene_file_path, Game.LEVELS[1], "Le niveau 2 doit etre charge")
	assert_eq(game.get_node("Interface/Niveau").text, "Level 2/%d" % Game.LEVELS.size())
	assert_true(level.next_requested.is_connected(game._on_level_next_requested), "Le nouveau niveau doit etre connecte")


func test_relancer_recharge_le_meme_niveau() -> void:
	var game := _add_game()
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
	var game := _add_game()
	_finish_all_levels(game, 300)

	var end_screen: Label = game.get_node("Interface/FinDuJeu")
	assert_true(end_screen.visible, "L'ecran de fin doit s'afficher")
	assert_string_contains(end_screen.text, str(300 * Game.LEVELS.size()), "Le total doit s'afficher")
	assert_null(_level(game), "Aucun niveau ne doit rester charge")


func test_r_sur_l_ecran_de_fin_revient_au_premier_niveau() -> void:
	var game := _add_game()
	_finish_all_levels(game, 300)

	game._unhandled_input(_pressed("restart"))

	assert_false(game.get_node("Interface/FinDuJeu").visible, "L'ecran de fin doit se cacher")
	assert_eq(_level(game).scene_file_path, Game.LEVELS[0], "Le jeu doit reprendre au niveau 1")


func test_r_pendant_le_jeu_n_est_pas_gere_par_le_jeu() -> void:
	var game := _add_game()
	var level := _level(game)
	game._unhandled_input(_pressed("restart"))
	assert_eq(_level(game), level, "Pendant un niveau, R est gere par le niveau")
