extends GutTest

const SCENE_PATH := "res://manager/patrolling_manager.tscn"
const TIME_TO_TURN_RIGHT := 4.5


func _add_manager() -> Node2D:
	var scene: PackedScene = load(SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func _add_body_at(x: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	body.add_child(shape)
	body.position.x = x
	return add_child_autofree(body)


func test_la_scene_s_instancie() -> void:
	var manager := _add_manager()
	assert_true(manager is Node2D, "Le manager doit etre un Node2D")
	assert_true(manager.get_node_or_null("Zone") is Area2D, "Le manager doit avoir une zone de detection")


func test_le_manager_ne_bloque_pas_le_joueur() -> void:
	assert_false(_add_manager() is PhysicsBody2D, "Le manager ne doit pas bloquer le joueur")


func test_la_zone_fait_150_pixels_de_large() -> void:
	var shape: RectangleShape2D = _add_manager().get_node("Zone/CollisionShape2D").shape
	assert_eq(shape.size.x, 150.0, "La zone doit faire 150 pixels de large")


func test_la_zone_visuelle_couvre_la_zone_de_detection() -> void:
	var manager := _add_manager()
	var shape: RectangleShape2D = manager.get_node("Zone/CollisionShape2D").shape
	assert_eq(manager.get_node("ZoneVisuelle").size.x, shape.size.x, "La bande doit avoir la largeur de la zone")


func test_le_manager_demarre_a_sa_limite_droite() -> void:
	var manager := _add_manager()
	assert_eq(manager.position.x, manager.right_limit, "Le manager doit demarrer a sa limite droite")


func test_le_manager_se_deplace() -> void:
	var manager := _add_manager()
	var start: float = manager.position.x
	manager._physics_process(1.0)
	assert_eq(manager.position.x, start - ManagerPatrol.SPEED, "Le manager doit avancer vers la gauche")


func test_en_allant_a_gauche_la_zone_est_a_gauche() -> void:
	var manager := _add_manager()
	var strip: ColorRect = manager.get_node("ZoneVisuelle")
	assert_eq(manager.get_node("Zone/CollisionShape2D").position.x, -75.0, "La zone doit etre devant le manager")
	assert_eq(strip.position.x, -150.0, "La bande doit etre devant le manager")


func test_en_allant_a_droite_la_zone_est_a_droite() -> void:
	var manager := _add_manager()
	var strip: ColorRect = manager.get_node("ZoneVisuelle")
	manager._physics_process(TIME_TO_TURN_RIGHT)
	assert_eq(manager.get_node("Zone/CollisionShape2D").position.x, 75.0, "La zone doit etre devant le manager")
	assert_eq(strip.position.x, 0.0, "La bande doit etre devant le manager")


func test_un_corps_devant_le_manager_est_repere() -> void:
	var manager := _add_manager()
	watch_signals(manager)
	var body := _add_body_at(manager.position.x - 75.0)
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(manager, "body_spotted", [body])


func test_un_corps_derriere_le_manager_n_est_pas_repere() -> void:
	var manager := _add_manager()
	watch_signals(manager)
	_add_body_at(manager.position.x + 75.0)
	await wait_physics_frames(5)
	assert_signal_not_emitted(manager, "body_spotted", "Le manager ne doit pas voir derriere lui")
