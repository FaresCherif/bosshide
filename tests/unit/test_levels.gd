extends GutTest

const LEVEL_SCRIPT_PATH := "res://level/level.gd"


func _instantiate(path: String) -> Node:
	var scene: PackedScene = load(path)
	return autofree(scene.instantiate())


func test_il_y_a_au_moins_deux_niveaux() -> void:
	assert_gte(Game.LEVELS.size(), 2, "Le jeu doit enchainer plusieurs niveaux")


func test_chaque_niveau_s_instancie_avec_le_script_de_niveau() -> void:
	for path: String in Game.LEVELS:
		assert_true(ResourceLoader.exists(path), "Le niveau doit exister : %s" % path)
		var level := _instantiate(path)
		assert_eq(level.get_script().resource_path, LEVEL_SCRIPT_PATH, "Le niveau doit utiliser level.gd : %s" % path)


func test_chaque_niveau_contient_l_essentiel() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		assert_true(level.get_node_or_null("Player") is CharacterBody2D, "Il faut un joueur : %s" % path)
		assert_true(level.get_node_or_null("Arrivee") is Area2D, "Il faut une arrivee : %s" % path)
		assert_true(level.get_node_or_null("Interface") is CanvasLayer, "Il faut l'interface : %s" % path)
		var managers := level.find_children("*", "", true, false).filter(
			func(node: Node) -> bool: return node.is_in_group("managers"))
		assert_gt(managers.size(), 0, "Il faut au moins un manager : %s" % path)


func test_dans_chaque_niveau_le_joueur_demarre_avant_l_arrivee() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		assert_lt(level.get_node("Player").position.x, level.get_node("Arrivee").position.x, "Le joueur doit demarrer avant l'arrivee : %s" % path)
