extends GutTest

# Niveau sans cle, sans digicode et sans collegue : le niveau doit marcher sans ces elements
const LEVEL_PATH := "res://levels/level_02.tscn"


func _add_level() -> Node:
	var scene: PackedScene = load(LEVEL_PATH)
	return add_child_autofree(scene.instantiate())


func _pressed(action: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


func test_le_niveau_n_a_pas_d_obstacle_optionnel() -> void:
	var level := _add_level()
	for name in ["Cle", "Porte", "PostIt", "PorteDigicode", "Collegue"]:
		assert_null(level.get_node_or_null(name), "Le niveau 2 ne doit pas contenir %s" % name)


func test_e_hors_bureau_ne_fait_rien() -> void:
	var level := _add_level()
	await wait_physics_frames(5)
	level._unhandled_input(_pressed("work"))
	assert_false(level.get_node("Player").is_working(), "E hors d'un bureau ne doit rien faire")


func test_atteindre_l_arrivee_reussit_le_niveau() -> void:
	var level := _add_level()
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	assert_true(level.get_node("Interface/MessageSucces").visible, "Le message de reussite doit s'afficher")
	assert_signal_emitted(level, "succeeded")


func test_le_manager_repere_le_joueur() -> void:
	var level := _add_level()
	var manager: Node2D = level.get_node("Manager")
	level.get_node("Player").position = manager.position + Vector2(-200, 0)
	await wait_physics_frames(5)
	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le manager doit reperer le joueur")
