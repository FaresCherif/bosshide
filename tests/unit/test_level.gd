extends GutTest

const MAIN_SCENE_PATH := "res://Scene.tscn"


func _load_level() -> Node:
	var scene: PackedScene = load(MAIN_SCENE_PATH)
	return scene.instantiate()


func _instantiate_level() -> Node:
	return autofree(_load_level())


func _action_keycodes(action: String) -> Array:
	var keycodes := []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keycodes.append(event.keycode)
	return keycodes


func test_le_niveau_contient_le_joueur() -> void:
	var player := _instantiate_level().get_node_or_null("Player")
	assert_true(player is CharacterBody2D, "Le niveau doit contenir le joueur")


func test_les_murs_encadrent_le_joueur_au_depart() -> void:
	var level := _instantiate_level()
	var player: Node2D = level.get_node("Player")
	var left_wall: Node2D = level.get_node("MurGauche")
	var right_wall: Node2D = level.get_node("MurDroit")
	var half_screen: float = ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0

	assert_true(left_wall is StaticBody2D, "Le mur gauche doit bloquer le joueur")
	assert_true(right_wall is StaticBody2D, "Le mur droit doit bloquer le joueur")
	assert_lt(left_wall.position.x, player.position.x, "Le mur gauche doit etre a gauche du joueur")
	assert_gt(right_wall.position.x, player.position.x + half_screen, "Le mur droit doit etre hors de l'ecran au depart")


func test_le_joueur_demarre_au_bord_gauche() -> void:
	var level := _instantiate_level()
	var player: Node2D = level.get_node("Player")
	var left_wall: Node2D = level.get_node("MurGauche")
	assert_lt(player.position.x - left_wall.position.x, 100.0, "Le joueur doit demarrer pres du mur gauche")


func test_l_arrivee_est_entre_le_joueur_et_le_mur_droit() -> void:
	var level := _instantiate_level()
	var goal: Node2D = level.get_node_or_null("Arrivee")
	assert_true(goal is Area2D, "Le niveau doit contenir une zone d'arrivee")
	assert_gt(goal.position.x, level.get_node("Player").position.x, "L'arrivee doit etre a droite du joueur")
	assert_lt(goal.position.x, level.get_node("MurDroit").position.x, "L'arrivee doit etre avant le mur droit")


func test_l_arrivee_est_collee_au_mur_droit() -> void:
	var level := _instantiate_level()
	var goal: Node2D = level.get_node("Arrivee")
	var right_wall: Node2D = level.get_node("MurDroit")
	var goal_shape: RectangleShape2D = goal.get_node("CollisionShape2D").shape
	var wall_shape: RectangleShape2D = right_wall.get_node("CollisionShape2D").shape

	var goal_right_edge := goal.position.x + goal_shape.size.x / 2.0
	var wall_left_edge := right_wall.position.x - wall_shape.size.x / 2.0
	assert_eq(goal_right_edge, wall_left_edge, "L'arrivee doit toucher le mur droit")


func test_le_signal_de_l_arrivee_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var goal: Area2D = level.get_node("Arrivee")
	assert_true(goal.body_entered.is_connected(level._on_arrivee_body_entered), "L'arrivee doit prevenir le niveau")


func test_le_message_de_succes_est_cache_au_depart() -> void:
	var message: Label = _instantiate_level().get_node("Interface/MessageSucces")
	assert_false(message.visible, "Le message de succes doit etre cache au depart")
	assert_string_contains(message.text, "Bravo, tu as atteint les toilettes !")


func test_un_autre_corps_ne_declenche_pas_le_succes() -> void:
	var level: Node = add_child_autofree(_load_level())
	var other: Node2D = autofree(StaticBody2D.new())
	level._on_arrivee_body_entered(other)
	assert_false(level.get_node("Interface/MessageSucces").visible, "Seul le joueur doit declencher le succes")


func test_le_joueur_dans_l_arrivee_declenche_le_succes() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	assert_true(player.is_physics_processing(), "Le joueur doit pouvoir bouger avant l'arrivee")

	player.position = level.get_node("Arrivee").position
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageSucces").visible, "Le message doit s'afficher a l'arrivee")
	assert_false(player.is_physics_processing(), "Le joueur doit etre fige a l'arrivee")


func test_action_rejouer_a_sa_touche() -> void:
	assert_true(InputMap.has_action("restart"), "L'action restart doit exister")
	assert_has(_action_keycodes("restart"), KEY_R, "La touche R doit relancer le niveau")


func test_action_gauche_a_ses_touches() -> void:
	assert_true(InputMap.has_action("move_left"), "L'action move_left doit exister")
	var keycodes := _action_keycodes("move_left")
	assert_has(keycodes, KEY_LEFT, "La fleche gauche doit deplacer le joueur")
	assert_has(keycodes, KEY_Q, "La touche Q doit deplacer le joueur")


func test_action_droite_a_ses_touches() -> void:
	assert_true(InputMap.has_action("move_right"), "L'action move_right doit exister")
	var keycodes := _action_keycodes("move_right")
	assert_has(keycodes, KEY_RIGHT, "La fleche droite doit deplacer le joueur")
	assert_has(keycodes, KEY_D, "La touche D doit deplacer le joueur")


func test_scene_principale_definie() -> void:
	assert_eq(ProjectSettings.get_setting("application/run/main_scene"), MAIN_SCENE_PATH, "F5 doit lancer le niveau")
