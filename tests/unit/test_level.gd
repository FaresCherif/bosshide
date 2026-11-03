extends GutTest

const MAIN_SCENE_PATH := "res://Scene.tscn"


func _instantiate_level() -> Node:
	var scene: PackedScene = load(MAIN_SCENE_PATH)
	return autofree(scene.instantiate())


func _action_keycodes(action: String) -> Array:
	var keycodes := []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keycodes.append(event.keycode)
	return keycodes


func test_le_niveau_contient_le_joueur() -> void:
	var player := _instantiate_level().get_node_or_null("Player")
	assert_true(player is CharacterBody2D, "Le niveau doit contenir le joueur")


func test_les_murs_entourent_le_joueur_hors_ecran() -> void:
	var level := _instantiate_level()
	var player: Node2D = level.get_node("Player")
	var left_wall: Node2D = level.get_node("MurGauche")
	var right_wall: Node2D = level.get_node("MurDroit")
	var half_screen: float = ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0

	assert_true(left_wall is StaticBody2D, "Le mur gauche doit bloquer le joueur")
	assert_true(right_wall is StaticBody2D, "Le mur droit doit bloquer le joueur")
	assert_lt(left_wall.position.x, player.position.x - half_screen, "Le mur gauche doit etre hors de l'ecran au depart")
	assert_gt(right_wall.position.x, player.position.x + half_screen, "Le mur droit doit etre hors de l'ecran au depart")


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
