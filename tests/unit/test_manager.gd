extends GutTest

const MANAGER_SCENE_PATH := "res://manager/manager.tscn"


func _add_manager() -> Node2D:
	var scene: PackedScene = load(MANAGER_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func _add_body_at_manager() -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	body.add_child(shape)
	return add_child_autofree(body)


func test_la_scene_du_manager_s_instancie() -> void:
	var manager := _add_manager()
	assert_true(manager is Node2D, "Le manager doit etre un Node2D")
	assert_true(manager.get_node_or_null("Zone") is Area2D, "Le manager doit avoir une zone de detection")


func test_le_manager_ne_bloque_pas_le_joueur() -> void:
	var manager := _add_manager()
	assert_false(manager is PhysicsBody2D, "Le manager est en arriere-plan, il ne doit pas bloquer")


func test_la_zone_fait_600_pixels_de_large() -> void:
	var manager := _add_manager()
	var shape: RectangleShape2D = manager.get_node("Zone/CollisionShape2D").shape
	assert_eq(shape.size.x, 600.0, "La zone doit faire 600 pixels de large")


func test_la_zone_visuelle_couvre_la_zone_de_detection() -> void:
	var manager := _add_manager()
	var shape: RectangleShape2D = manager.get_node("Zone/CollisionShape2D").shape
	var strip: ColorRect = manager.get_node("ZoneVisuelle")
	assert_eq(strip.size.x, shape.size.x, "La bande doit avoir la largeur de la zone")


func test_de_face_la_bande_est_visible() -> void:
	var manager := _add_manager()
	assert_true(manager.get_node("ZoneVisuelle").visible, "La bande doit etre visible de face")
	assert_eq(manager.get_node("Visuel").color, manager.FACING_COLOR, "Le manager doit avoir sa couleur de face")


func test_de_dos_la_bande_est_cachee_et_la_couleur_change() -> void:
	var manager := _add_manager()
	manager._physics_process(ManagerWatch.FACING_DURATION)
	assert_false(manager.get_node("ZoneVisuelle").visible, "La bande doit etre cachee de dos")
	assert_eq(manager.get_node("Visuel").color, manager.BACK_COLOR, "Le manager doit avoir sa couleur de dos")


func test_de_face_un_corps_dans_la_zone_est_repere() -> void:
	var manager := _add_manager()
	watch_signals(manager)
	var body := _add_body_at_manager()
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(manager, "body_spotted", [body])


func test_de_dos_un_corps_dans_la_zone_n_est_pas_repere() -> void:
	var manager := _add_manager()
	manager._physics_process(ManagerWatch.FACING_DURATION)
	watch_signals(manager)
	_add_body_at_manager()
	await wait_physics_frames(5)
	assert_signal_not_emitted(manager, "body_spotted", "De dos le manager ne doit reperer personne")
