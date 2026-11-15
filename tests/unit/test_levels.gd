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


# Contenu attendu de chaque niveau : managers fixes, patrouilleurs, obstacles optionnels, affiche, limite de temps
const EXPECTED := [
	{"watching": 1, "patrolling": 0, "nodes": [], "sign": true, "timed": false},
	{"watching": 2, "patrolling": 0, "nodes": [], "sign": false, "timed": false},
	{"watching": 1, "patrolling": 0, "nodes": ["Cle", "Porte"], "sign": true, "timed": false},
	{"watching": 0, "patrolling": 1, "nodes": [], "sign": true, "timed": false},
	{"watching": 1, "patrolling": 1, "nodes": ["PostIt", "PorteDigicode"], "sign": true, "timed": false},
	{"watching": 1, "patrolling": 1, "nodes": ["Collegue"], "sign": true, "timed": false},
	{"watching": 1, "patrolling": 1, "nodes": ["Cle", "Porte"], "sign": false, "timed": false},
	{"watching": 2, "patrolling": 1, "nodes": ["PostIt", "PorteDigicode", "Collegue"], "sign": false, "timed": false},
	{"watching": 2, "patrolling": 1, "nodes": ["Cle", "Porte", "PostIt", "PorteDigicode", "Collegue"], "sign": true, "timed": true},
	{"watching": 2, "patrolling": 2, "nodes": ["Cle", "Porte", "PostIt", "PorteDigicode", "Collegue"], "sign": false, "timed": true},
]
const OPTIONAL_NODES := ["Cle", "Porte", "PostIt", "PorteDigicode", "Collegue"]
const DESK_HALF_WIDTH := 40.0
const PATROL_SCRIPT := preload("res://manager/patrolling_manager.gd")


func _in_group(level: Node, group: String) -> Array:
	return level.find_children("*", "", true, false).filter(
		func(node: Node) -> bool: return node.is_in_group(group))


func _desks_x(level: Node) -> Array:
	return _in_group(level, "desks").map(func(desk: Node2D) -> float: return desk.global_position.x)


func test_le_jeu_compte_dix_niveaux() -> void:
	assert_eq(Game.LEVELS.size(), 10, "Le jeu doit avoir 10 niveaux")
	assert_eq(EXPECTED.size(), Game.LEVELS.size(), "Chaque niveau a son contenu attendu")


func test_chaque_niveau_introduit_ses_mecaniques() -> void:
	for i in Game.LEVELS.size():
		var path: String = Game.LEVELS[i]
		var level := _instantiate(path)
		var expected: Dictionary = EXPECTED[i]
		var patrols := _in_group(level, "patrolling_managers").size()
		assert_eq(patrols, expected["patrolling"], "Nombre de patrouilleurs : %s" % path)
		assert_eq(_in_group(level, "managers").size() - patrols, expected["watching"], "Nombre de managers fixes : %s" % path)
		for name: String in OPTIONAL_NODES:
			assert_eq(level.has_node(name), name in expected["nodes"], "%s present ou absent comme prevu : %s" % [name, path])


func test_les_affiches_de_tutoriel_annoncent_les_nouveautes() -> void:
	for i in Game.LEVELS.size():
		var path: String = Game.LEVELS[i]
		var signs := _instantiate(path).find_children("*", "Node2D", true, false).filter(
			func(node: Node) -> bool: return node is TutorialSign)
		assert_eq(signs.size() > 0, EXPECTED[i]["sign"], "Affiche de tutoriel comme prevu : %s" % path)
		for sign: TutorialSign in signs:
			assert_ne(sign.text, "", "L'affiche doit avoir un texte : %s" % path)


func test_seuls_les_derniers_niveaux_ont_une_limite_de_temps() -> void:
	for i in Game.LEVELS.size():
		var path: String = Game.LEVELS[i]
		var limit: float = _instantiate(path).time_limit
		assert_eq(limit > 0.0, EXPECTED[i]["timed"], "Limite de temps comme prevu : %s" % path)


func test_chaque_manager_fixe_a_un_bureau_dans_sa_zone() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		for manager: Node2D in _in_group(level, "managers"):
			if manager.is_in_group("patrolling_managers"):
				continue
			var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0
			var covered := _desks_x(level).filter(
				func(x: float) -> bool: return absf(x - manager.position.x) <= half_zone - DESK_HALF_WIDTH)
			assert_gt(covered.size(), 0, "Un bureau doit abriter le joueur dans la zone de %s : %s" % [manager.name, path])


func test_chaque_patrouilleur_a_un_bureau_sur_sa_ronde() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		for manager: Node2D in _in_group(level, "patrolling_managers"):
			assert_lt(manager.left_limit, manager.right_limit, "Limites dans l'ordre : %s" % path)
			var covered := _desks_x(level).filter(
				func(x: float) -> bool: return x >= manager.left_limit and x <= manager.right_limit)
			assert_gt(covered.size(), 0, "Un bureau doit etre sur la ronde de %s : %s" % [manager.name, path])


func test_les_managers_fixes_d_un_niveau_ne_sont_pas_synchrones() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		var offsets := {}
		for manager: Node2D in _in_group(level, "managers"):
			if not manager.is_in_group("patrolling_managers"):
				offsets[manager.start_offset] = true
		var watching: int = _in_group(level, "managers").size() - _in_group(level, "patrolling_managers").size()
		assert_eq(offsets.size(), watching, "Chaque manager fixe a son propre decalage : %s" % path)


func test_les_obstacles_sont_dans_l_ordre_sur_le_chemin() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		var start: float = level.get_node("Player").position.x
		var goal: float = level.get_node("Arrivee").position.x
		for door in ["Porte", "PorteDigicode"]:
			if level.has_node(door):
				var x: float = level.get_node(door).position.x
				assert_true(x > start and x < goal, "%s entre le depart et l'arrivee : %s" % [door, path])
		if level.has_node("Cle"):
			var key_x: float = level.get_node("Cle").position.x
			assert_lt(key_x, level.get_node("Porte").position.x, "La cle avant sa porte : %s" % path)
			assert_true(key_x in _desks_x(level), "La cle est posee sur un bureau : %s" % path)
		if level.has_node("PostIt"):
			var post_it_x: float = level.get_node("PostIt").position.x
			assert_true(post_it_x > start and post_it_x < level.get_node("PorteDigicode").position.x, "Le post-it avant le digicode : %s" % path)
		if level.has_node("Collegue"):
			var colleague_x: float = level.get_node("Collegue").position.x
			assert_true(colleague_x > start and colleague_x < goal, "Le collegue sur le chemin : %s" % path)


func test_les_niveaux_s_allongent() -> void:
	var previous := 0.0
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		var width: float = level.get_node("MurDroit").position.x - level.get_node("MurGauche").position.x
		assert_gte(width, previous, "Un niveau n'est pas plus court que le precedent : %s" % path)
		previous = width


func _watching_managers(level: Node) -> Array:
	return _in_group(level, "managers").filter(
		func(manager: Node) -> bool: return not manager.is_in_group("patrolling_managers"))


# Etendue surveillee : la zone d'un manager fixe, ou la ronde d'un patrouilleur plus sa vision
func _watched_span(manager: Node2D) -> Vector2:
	if manager.is_in_group("patrolling_managers"):
		return Vector2(manager.left_limit - PATROL_SCRIPT.VISION_LENGTH, manager.right_limit + PATROL_SCRIPT.VISION_LENGTH)
	var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0
	return Vector2(manager.position.x - half_zone, manager.position.x + half_zone)


func test_les_zones_des_managers_ne_se_chevauchent_pas() -> void:
	for path: String in Game.LEVELS:
		var managers := _in_group(_instantiate(path), "managers")
		for a in managers.size():
			for b in range(a + 1, managers.size()):
				var span_a := _watched_span(managers[a])
				var span_b := _watched_span(managers[b])
				assert_true(span_a.y <= span_b.x or span_b.y <= span_a.x, "%s et %s se chevauchent : %s" % [managers[a].name, managers[b].name, path])


func test_les_managers_fixes_balaient_sans_pause_au_dessus_d_un_bureau_central() -> void:
	for path: String in Game.LEVELS:
		var level := _instantiate(path)
		for manager: Node2D in _watching_managers(level):
			assert_eq(manager.back_duration, 0.0, "%s ne se retourne jamais : %s" % [manager.name, path])
			var span := _watched_span(manager)
			var desks := _desks_x(level).filter(func(x: float) -> bool: return x > span.x and x < span.y)
			assert_eq(desks, [manager.position.x], "Un seul bureau, au milieu de la zone de %s : %s" % [manager.name, path])
