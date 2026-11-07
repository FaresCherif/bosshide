extends GutTest

const MANAGER_SCENE_PATH := "res://manager/manager.tscn"
const LEFT_SECTOR_X := -200.0
const RIGHT_SECTOR_X := 200.0


func _add_manager() -> Node2D:
	var scene: PackedScene = load(MANAGER_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func _add_body_at_manager() -> StaticBody2D:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	body.add_child(shape)
	return add_child_autofree(body)


func _add_body_at(x: float) -> StaticBody2D:
	var body := _add_body_at_manager()
	body.position.x = x
	return body


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
	var body := _add_body_at(LEFT_SECTOR_X)
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(manager, "body_spotted", [body])


func test_de_dos_un_corps_dans_la_zone_n_est_pas_repere() -> void:
	var manager := _add_manager()
	manager._physics_process(ManagerWatch.FACING_DURATION)
	watch_signals(manager)
	_add_body_at_manager()
	await wait_physics_frames(5)
	assert_signal_not_emitted(manager, "body_spotted", "De dos le manager ne doit reperer personne")


func test_de_dos_un_corps_dans_la_zone_gauche_n_est_pas_repere() -> void:
	var manager := _add_manager()
	manager._physics_process(ManagerWatch.FACING_DURATION)
	watch_signals(manager)
	_add_body_at(LEFT_SECTOR_X)
	await wait_physics_frames(5)
	assert_signal_not_emitted(manager, "body_spotted", "De dos le manager ne doit reperer personne")


func test_un_corps_hors_de_la_zone_regardee_n_est_pas_repere() -> void:
	var manager := _add_manager()
	watch_signals(manager)
	_add_body_at(RIGHT_SECTOR_X)
	await wait_physics_frames(5)
	assert_signal_not_emitted(manager, "body_spotted", "En regardant a gauche le manager ne doit pas voir a droite")


func test_un_corps_a_droite_est_repere_quand_le_manager_y_regarde() -> void:
	var manager := _add_manager()
	manager._physics_process(ManagerWatch.SECTOR_DURATION * 2.0)
	watch_signals(manager)
	var body := _add_body_at(RIGHT_SECTOR_X)
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(manager, "body_spotted", [body])


func test_le_secteur_visuel_fait_un_tiers_de_la_zone() -> void:
	var manager := _add_manager()
	var shape: RectangleShape2D = manager.get_node("Zone/CollisionShape2D").shape
	assert_eq(manager.get_node("SecteurVisuel").size.x, shape.size.x / 3.0, "Le secteur doit faire un tiers de la zone")


func test_le_secteur_visuel_suit_le_regard() -> void:
	var manager := _add_manager()
	var sector: ColorRect = manager.get_node("SecteurVisuel")
	assert_eq(sector.position.x, -300.0, "Le secteur doit commencer a gauche")
	manager._physics_process(ManagerWatch.SECTOR_DURATION)
	assert_eq(sector.position.x, -100.0, "Le secteur doit passer au centre")
	manager._physics_process(ManagerWatch.SECTOR_DURATION)
	assert_eq(sector.position.x, 100.0, "Le secteur doit passer a droite")


func test_le_secteur_visuel_est_cache_de_dos() -> void:
	var manager := _add_manager()
	assert_true(manager.get_node("SecteurVisuel").visible, "Le secteur doit etre visible de face")
	manager._physics_process(ManagerWatch.FACING_DURATION)
	assert_false(manager.get_node("SecteurVisuel").visible, "Le secteur doit etre cache de dos")


func test_la_fleche_est_au_dessus_du_manager() -> void:
	var manager := _add_manager()
	var arrow: Node2D = manager.get_node_or_null("Fleche")
	assert_not_null(arrow, "Le manager doit avoir une fleche")
	assert_lt(arrow.position.y, manager.get_node("Visuel").offset_top, "La fleche doit etre au-dessus du manager")


func test_la_fleche_tourne_avec_le_regard() -> void:
	var manager := _add_manager()
	var arrow: Node2D = manager.get_node("Fleche")
	assert_almost_eq(arrow.rotation, manager.ARROW_MAX_ANGLE, 0.001, "La fleche doit commencer a gauche")
	manager._physics_process(3.0)
	assert_almost_eq(arrow.rotation, 0.0, 0.001, "La fleche doit pointer vers le bas au centre")
	manager._physics_process(2.0)
	assert_almost_eq(arrow.rotation, -manager.ARROW_MAX_ANGLE, 0.001, "La fleche doit finir a droite")


func test_la_fleche_glisse_entre_deux_zones() -> void:
	var manager := _add_manager()
	manager._physics_process(2.5)
	var expected: float = manager.ARROW_MAX_ANGLE * 0.25
	assert_almost_eq(manager.get_node("Fleche").rotation, expected, 0.001, "La fleche doit etre entre deux zones")


func test_la_fleche_est_cachee_de_dos_puis_previent_du_retournement() -> void:
	var manager := _add_manager()
	var arrow: Node2D = manager.get_node("Fleche")
	assert_true(arrow.visible, "La fleche doit etre visible de face")
	manager._physics_process(ManagerWatch.FACING_DURATION)
	assert_false(arrow.visible, "La fleche doit etre cachee de dos")
	manager._physics_process(4.5)
	assert_true(arrow.visible, "La fleche doit reapparaitre juste avant le retournement")
