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


func test_chaque_niveau_a_un_decor_d_open_space_en_parallaxe() -> void:
	var paths: Array = Game.LEVELS.duplicate()
	paths.append("res://levels/test_collegue.tscn")
	for path: String in paths:
		var scene: PackedScene = load(path)
		var level: Node = add_child_autofree(scene.instantiate())
		var decor := level.get_node_or_null("Decor")
		assert_true(decor is ParallaxBackground, "Le niveau doit avoir un decor : %s" % path)
		if decor == null:
			continue
		assert_lt(decor.layer, 0, "Le decor doit etre derriere le jeu : %s" % path)
		var layer: ParallaxLayer = decor.get_child(0)
		assert_eq(layer.motion_mirroring.x, OfficeBackdrop.TILE_WIDTH, "Le decor doit se repeter : %s" % path)
		assert_lt(layer.motion_scale.x, 1.0, "Le decor doit defiler plus lentement : %s" % path)


func _level_paths() -> Array:
	var paths: Array = Game.LEVELS.duplicate()
	paths.append("res://levels/test_collegue.tscn")
	return paths


func _wall_rect(wall: Node2D) -> Rect2:
	var shape: RectangleShape2D = wall.get_node("CollisionShape2D").shape
	return LevelBounds.wall_rect(wall.position, shape.size)


func test_la_camera_s_arrete_aux_murs_du_batiment() -> void:
	for path: String in _level_paths():
		var scene: PackedScene = load(path)
		var level: Node = add_child_autofree(scene.instantiate())
		var camera: Camera2D = level.get_node("Player/Camera2D")
		assert_eq(camera.limit_left, int(_wall_rect(level.get_node("MurGauche")).position.x), "La camera s'arrete au mur de gauche : %s" % path)
		assert_eq(camera.limit_right, int(_wall_rect(level.get_node("MurDroit")).end.x), "La camera s'arrete au mur de droite : %s" % path)
		assert_eq(camera.limit_bottom, LevelBounds.camera_bottom(level.get_node("Sol").get_rect()), "La camera s'arrete sous le sol : %s" % path)


func test_les_murs_sont_en_beton() -> void:
	for path: String in _level_paths():
		var level := _instantiate(path)
		for wall in ["MurGauche", "MurDroit"]:
			var color: Color = level.get_node(wall + "/Visuel").color
			assert_lt(color.s, 0.15, "Le mur doit etre gris beton, pas rouge : %s %s" % [path, wall])


func test_les_niveaux_n_ont_plus_de_reperes_au_sol() -> void:
	for path: String in _level_paths():
		assert_null(_instantiate(path).get_node_or_null("Reperes"), "Le decor remplace les reperes au sol : %s" % path)


func test_les_murs_montent_jusqu_en_haut_de_l_ecran() -> void:
	var screen_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	for path: String in _level_paths():
		var level := _instantiate(path)
		var camera_top := LevelBounds.camera_bottom(level.get_node("Sol").get_rect()) - screen_height
		for wall in ["MurGauche", "MurDroit"]:
			var visual: Control = level.get_node(wall + "/Visuel")
			assert_lte(level.get_node(wall).position.y + visual.offset_top, camera_top, "Le mur doit couvrir tout l'ecran : %s %s" % [path, wall])


func test_le_joueur_demarre_a_son_bureau() -> void:
	for path: String in _level_paths():
		var scene: PackedScene = load(path)
		var level: Node = add_child_autofree(scene.instantiate())
		var desk: Node2D = level.get_node_or_null("BureauPerso")
		assert_not_null(desk, "Le joueur doit avoir son bureau : %s" % path)
		if desk == null:
			continue
		var player: Node2D = level.get_node("Player")
		assert_true(desk.is_in_group("desks"), "C'est un vrai bureau de travail : %s" % path)
		assert_eq(desk.position.x, player.position.x, "Le bureau est au point de depart : %s" % path)
		assert_lt(desk.get_index(), player.get_index(), "Le joueur est dessine devant son bureau : %s" % path)
		assert_gt(desk.position.x - 40.0, _wall_rect(level.get_node("MurGauche")).end.x - 0.1, "Le bureau est dans le batiment : %s" % path)
