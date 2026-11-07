extends GutTest

const PLAYER_SCENE_PATH := "res://player/player.tscn"


func _instantiate_player() -> Node:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	return autofree(scene.instantiate())


func test_player_est_un_character_body() -> void:
	assert_true(_instantiate_player() is CharacterBody2D, "Le joueur doit etre un CharacterBody2D")


func test_player_a_une_camera() -> void:
	var cameras := _instantiate_player().find_children("*", "Camera2D")
	assert_eq(cameras.size(), 1, "Le joueur doit porter une camera qui le suit")


func test_player_a_une_collision() -> void:
	var shapes := _instantiate_player().find_children("*", "CollisionShape2D")
	assert_eq(shapes.size(), 1, "Le joueur doit avoir une forme de collision")


func test_player_a_un_rectangle_visible() -> void:
	var rects := _instantiate_player().find_children("*", "ColorRect")
	assert_eq(rects.size(), 1, "Le joueur doit etre affiche par un rectangle")


func _add_player() -> Node:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func _pressed(action: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


func test_au_repos_le_joueur_a_sa_couleur_normale() -> void:
	var player := _add_player()
	assert_eq(player.get_node("Rectangle").color, player.NORMAL_COLOR, "Le joueur doit avoir sa couleur normale")


func test_au_travail_le_joueur_change_de_couleur() -> void:
	var player := _add_player()
	player.press_work(true)
	assert_eq(player.get_node("Rectangle").color, player.WORKING_COLOR, "Le joueur doit changer de couleur au travail")


func test_apres_le_travail_le_joueur_retrouve_sa_couleur() -> void:
	var player := _add_player()
	player.press_work(true)
	player.press_work(true)
	assert_eq(player.get_node("Rectangle").color, player.NORMAL_COLOR, "Le joueur doit retrouver sa couleur normale")


func test_une_touche_maintenue_ne_deplace_pas_le_joueur_au_travail() -> void:
	var player := _add_player()
	Input.action_press("move_right")
	player.press_work(true)
	player._physics_process(0.016)
	Input.action_release("move_right")
	assert_eq(player.velocity.x, 0.0, "Le joueur doit rester immobile au travail")
	assert_true(player.is_working(), "Une touche deja maintenue ne doit pas arreter le travail")


func test_un_appui_a_gauche_arrete_le_travail() -> void:
	var player := _add_player()
	player.press_work(true)
	player._unhandled_input(_pressed("move_left"))
	assert_false(player.is_working(), "Un appui a gauche doit arreter le travail")
	assert_eq(player.get_node("Rectangle").color, player.NORMAL_COLOR, "Le joueur doit retrouver sa couleur normale")


func test_un_appui_a_droite_arrete_le_travail() -> void:
	var player := _add_player()
	player.press_work(true)
	player._unhandled_input(_pressed("move_right"))
	assert_false(player.is_working(), "Un appui a droite doit arreter le travail")
