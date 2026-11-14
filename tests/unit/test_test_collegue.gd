extends GutTest

# Scene de test du collegue : lancee a la main avec F6, hors de Game.LEVELS
const SCENE_PATH := "res://levels/test_collegue.tscn"


func _load() -> Node:
	var scene: PackedScene = load(SCENE_PATH)
	return scene.instantiate()


func test_la_scene_a_le_minimum_pour_un_niveau() -> void:
	var level: Node = autofree(_load())
	for name in ["Player", "Collegue", "Arrivee", "Interface"]:
		assert_not_null(level.get_node_or_null(name), "La scene doit contenir " + name)
	assert_false(Game.LEVELS.has(SCENE_PATH), "La scene de test ne doit pas etre dans le jeu")


func test_le_joueur_demarre_juste_avant_le_collegue_sans_manager() -> void:
	var level: Node = add_child_autofree(_load())
	var gap: float = level.get_node("Collegue").position.x - level.get_node("Player").position.x
	assert_between(gap, 40.0, 150.0, "Le joueur doit demarrer juste a gauche du collegue")
	assert_eq(get_tree().get_nodes_in_group("managers").filter(func(m): return level.is_ancestor_of(m)).size(), 0, "Pas de manager")


func test_avancer_lance_la_question() -> void:
	var level: Node = add_child_autofree(_load())
	Input.action_press("move_right")
	await wait_physics_frames(40)
	Input.action_release("move_right")
	assert_true(level.get_node("Interface/Collegue").visible, "La question doit s'ouvrir en avancant")
