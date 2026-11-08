extends GutTest

const MAIN_SCENE_PATH := "res://Scene.tscn"
const LEFT_SECTOR_OFFSET := Vector2(-200, 0)


func _load_level() -> Node:
	var scene: PackedScene = load(MAIN_SCENE_PATH)
	return scene.instantiate()


func _instantiate_level() -> Node:
	return autofree(_load_level())


func _action_keycodes(action: String) -> Array:
	var keycodes := []
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			keycodes.append(event.keycode)
	return keycodes


func test_le_niveau_contient_le_joueur() -> void:
	var player := _instantiate_level().get_node_or_null("Player")
	assert_true(player is CharacterBody2D, "Le niveau doit contenir le joueur")


func test_les_murs_encadrent_le_joueur_au_depart() -> void:
	var level := _instantiate_level()
	var player: Node2D = level.get_node("Player")
	var left_wall: Node2D = level.get_node("MurGauche")
	var right_wall: Node2D = level.get_node("MurDroit")
	var half_screen: float = ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0

	assert_true(left_wall is StaticBody2D, "Le mur gauche doit bloquer le joueur")
	assert_true(right_wall is StaticBody2D, "Le mur droit doit bloquer le joueur")
	assert_lt(left_wall.position.x, player.position.x, "Le mur gauche doit etre a gauche du joueur")
	assert_gt(right_wall.position.x, player.position.x + half_screen, "Le mur droit doit etre hors de l'ecran au depart")


func test_le_joueur_demarre_au_bord_gauche() -> void:
	var level := _instantiate_level()
	var player: Node2D = level.get_node("Player")
	var left_wall: Node2D = level.get_node("MurGauche")
	assert_lt(player.position.x - left_wall.position.x, 100.0, "Le joueur doit demarrer pres du mur gauche")


func test_l_arrivee_est_entre_le_joueur_et_le_mur_droit() -> void:
	var level := _instantiate_level()
	var goal: Node2D = level.get_node_or_null("Arrivee")
	assert_true(goal is Area2D, "Le niveau doit contenir une zone d'arrivee")
	assert_gt(goal.position.x, level.get_node("Player").position.x, "L'arrivee doit etre a droite du joueur")
	assert_lt(goal.position.x, level.get_node("MurDroit").position.x, "L'arrivee doit etre avant le mur droit")


func test_l_arrivee_est_collee_au_mur_droit() -> void:
	var level := _instantiate_level()
	var goal: Node2D = level.get_node("Arrivee")
	var right_wall: Node2D = level.get_node("MurDroit")
	var goal_shape: RectangleShape2D = goal.get_node("CollisionShape2D").shape
	var wall_shape: RectangleShape2D = right_wall.get_node("CollisionShape2D").shape

	var goal_right_edge := goal.position.x + goal_shape.size.x / 2.0
	var wall_left_edge := right_wall.position.x - wall_shape.size.x / 2.0
	assert_eq(goal_right_edge, wall_left_edge, "L'arrivee doit toucher le mur droit")


func test_le_signal_de_l_arrivee_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var goal: Area2D = level.get_node("Arrivee")
	assert_true(goal.body_entered.is_connected(level._on_arrivee_body_entered), "L'arrivee doit prevenir le niveau")


func test_le_message_de_succes_est_cache_au_depart() -> void:
	var message: Label = _instantiate_level().get_node("Interface/MessageSucces")
	assert_false(message.visible, "Le message de succes doit etre cache au depart")
	assert_string_contains(message.text, "Well done, you made it to the toilets!")


func test_un_autre_corps_ne_declenche_pas_le_succes() -> void:
	var level: Node = add_child_autofree(_load_level())
	var other: Node2D = autofree(StaticBody2D.new())
	level._on_arrivee_body_entered(other)
	assert_false(level.get_node("Interface/MessageSucces").visible, "Seul le joueur doit declencher le succes")


func test_le_joueur_dans_l_arrivee_declenche_le_succes() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	assert_true(player.is_physics_processing(), "Le joueur doit pouvoir bouger avant l'arrivee")

	player.position = level.get_node("Arrivee").position
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageSucces").visible, "Le message doit s'afficher a l'arrivee")
	assert_false(player.is_physics_processing(), "Le joueur doit etre fige a l'arrivee")


func test_le_manager_est_au_milieu_du_parcours() -> void:
	var level := _instantiate_level()
	var manager: Node2D = level.get_node_or_null("Manager")
	assert_not_null(manager, "Le niveau doit contenir le manager")
	var middle: float = (level.get_node("MurGauche").position.x + level.get_node("MurDroit").position.x) / 2.0
	assert_eq(manager.position.x, middle, "Le manager doit etre au milieu du parcours")


func test_le_manager_est_dessine_derriere_le_joueur() -> void:
	var level := _instantiate_level()
	var manager_index: int = level.get_node("Manager").get_index()
	assert_lt(manager_index, level.get_node("Player").get_index(), "Le manager doit etre en arriere-plan")


func test_le_message_de_game_over_est_cache_au_depart() -> void:
	var message: Label = _instantiate_level().get_node("Interface/MessageGameOver")
	assert_false(message.visible, "Le message de game over doit etre cache au depart")
	assert_string_contains(message.text, "Game over")


func test_le_signal_du_manager_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var manager: Node = level.get_node("Manager")
	assert_true(manager.body_spotted.is_connected(level._on_manager_body_spotted), "Le manager doit prevenir le niveau")


func test_un_autre_corps_ne_declenche_pas_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	var other: Node2D = autofree(StaticBody2D.new())
	level._on_manager_body_spotted(other)
	assert_false(level.get_node("Interface/MessageGameOver").visible, "Seul le joueur doit declencher le game over")


func test_le_joueur_vu_de_face_declenche_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	var manager: Node2D = level.get_node("Manager")

	player.position = manager.position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le message doit s'afficher")
	assert_false(player.is_physics_processing(), "Le joueur doit etre fige au game over")
	assert_false(manager.is_physics_processing(), "Le manager doit arreter son cycle au game over")


func test_le_joueur_passe_quand_le_manager_est_de_dos() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	var manager: Node2D = level.get_node("Manager")

	manager._physics_process(ManagerWatch.FACING_DURATION)
	player.position = manager.position
	await wait_physics_frames(5)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "De dos il ne doit pas y avoir de game over")
	assert_true(player.is_physics_processing(), "Le joueur doit pouvoir continuer")


func test_le_joueur_dans_la_zone_au_retournement_declenche_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	var manager: Node2D = level.get_node("Manager")

	manager._physics_process(ManagerWatch.FACING_DURATION)
	player.position = manager.position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)
	manager._physics_process(ManagerWatch.BACK_DURATION)
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le joueur reste dans la zone : game over")


func test_la_victoire_arrete_le_manager() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	player.position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	assert_false(level.get_node("Manager").is_physics_processing(), "Le manager doit s'arreter a la victoire")


func test_action_rejouer_a_sa_touche() -> void:
	assert_true(InputMap.has_action("restart"), "L'action restart doit exister")
	assert_has(_action_keycodes("restart"), KEY_R, "La touche R doit relancer le niveau")


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


func _pressed(action: String) -> InputEventAction:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	return event


# Met le manager de dos pour que le joueur ne soit pas repere avant d'appuyer sur E
func _place_player_on_desk_behind_manager(level: Node) -> void:
	level.get_node("Manager")._physics_process(ManagerWatch.FACING_DURATION)
	level.get_node("Player").position = level.get_node("Bureaux/Bureau1").position
	await wait_physics_frames(5)
	# Bureau1 porte la cle : le premier appui la prend, les suivants font travailler
	level._unhandled_input(_pressed("work"))


func test_action_travailler_a_sa_touche() -> void:
	assert_true(InputMap.has_action("work"), "L'action work doit exister")
	assert_has(_action_keycodes("work"), KEY_E, "La touche E doit faire travailler le joueur")


func test_le_niveau_a_deux_bureaux_dans_la_zone_du_manager() -> void:
	var level := _instantiate_level()
	var manager: Node2D = level.get_node("Manager")
	var zone_shape: RectangleShape2D = manager.get_node("Zone/CollisionShape2D").shape
	var desks: Array = level.get_node("Bureaux").get_children()

	assert_eq(desks.size(), 2, "Le niveau doit contenir deux bureaux")
	for desk in desks:
		assert_lt(abs(desk.position.x - manager.position.x), zone_shape.size.x / 2.0, "Le bureau doit etre dans la zone")


func test_les_bureaux_sont_dessines_derriere_le_joueur() -> void:
	var level := _instantiate_level()
	assert_lt(level.get_node("Bureaux").get_index(), level.get_node("Player").get_index(), "Les bureaux doivent etre derriere le joueur")


func test_e_sur_un_bureau_fait_travailler_le_joueur() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_desk_behind_manager(level)

	level._unhandled_input(_pressed("work"))

	assert_true(level.get_node("Player").is_working(), "E sur un bureau doit faire travailler le joueur")


func test_e_hors_bureau_ne_fait_rien() -> void:
	var level: Node = add_child_autofree(_load_level())
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("work"))

	assert_false(level.get_node("Player").is_working(), "E hors d'un bureau ne doit rien faire")


func test_au_travail_le_manager_de_face_ne_repere_pas_le_joueur() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_desk_behind_manager(level)

	level._unhandled_input(_pressed("work"))
	level.get_node("Manager")._physics_process(ManagerWatch.BACK_DURATION)
	await wait_physics_frames(5)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "Au travail il ne doit pas y avoir de game over")
	assert_true(level.get_node("Manager").is_physics_processing(), "Le manager doit continuer son cycle")


func test_quitter_le_travail_devant_le_manager_declenche_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_desk_behind_manager(level)

	level._unhandled_input(_pressed("work"))
	level.get_node("Manager")._physics_process(ManagerWatch.BACK_DURATION)
	await wait_physics_frames(5)
	level._unhandled_input(_pressed("work"))
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Hors du travail le joueur doit etre repere")


func test_e_est_sans_effet_apres_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")

	player.position = level.get_node("Bureaux/Bureau1").position
	await wait_physics_frames(5)
	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le joueur doit etre repere avant de travailler")

	level._unhandled_input(_pressed("work"))

	assert_false(player.is_working(), "E ne doit plus rien faire apres le game over")


func _add_level_with_fixed_manager_back() -> Node:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Manager")._physics_process(ManagerWatch.FACING_DURATION)
	return level


func test_la_patrouille_couvre_la_zone_du_manager_fixe() -> void:
	var level := _instantiate_level()
	var manager: Node2D = level.get_node("Manager")
	var patrol: Node2D = level.get_node_or_null("ManagerPatrouille")
	var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0

	assert_not_null(patrol, "Le niveau doit contenir le manager qui patrouille")
	assert_eq(patrol.left_limit, manager.position.x - half_zone, "La patrouille doit commencer au bord gauche de la zone")
	assert_eq(patrol.right_limit, manager.position.x + half_zone, "La patrouille doit finir au bord droit de la zone")


func test_le_manager_qui_patrouille_est_dessine_derriere_le_joueur() -> void:
	var level := _instantiate_level()
	var patrol_index: int = level.get_node("ManagerPatrouille").get_index()
	assert_lt(patrol_index, level.get_node("Player").get_index(), "Le manager doit etre derriere le joueur")


func test_le_signal_du_manager_qui_patrouille_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var patrol: Node = level.get_node("ManagerPatrouille")
	assert_true(patrol.body_spotted.is_connected(level._on_manager_body_spotted), "Le manager doit prevenir le niveau")


func test_le_joueur_devant_le_manager_qui_patrouille_declenche_le_game_over() -> void:
	var level := _add_level_with_fixed_manager_back()
	var patrol: Node2D = level.get_node("ManagerPatrouille")

	level.get_node("Player").position.x = patrol.position.x - 75.0
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le joueur devant le manager doit etre repere")
	assert_false(patrol.is_physics_processing(), "Le manager doit s'arreter au game over")


func test_le_joueur_derriere_le_manager_qui_patrouille_n_est_pas_repere() -> void:
	var level := _add_level_with_fixed_manager_back()
	var player: CharacterBody2D = level.get_node("Player")

	player.position.x = level.get_node("ManagerPatrouille").position.x + 75.0
	await wait_physics_frames(5)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "Le joueur derriere le manager ne doit pas etre repere")
	assert_true(player.is_physics_processing(), "Le joueur doit pouvoir continuer")


func test_au_travail_le_manager_qui_patrouille_ne_repere_pas_le_joueur() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_desk_behind_manager(level)

	level._unhandled_input(_pressed("work"))
	level.get_node("ManagerPatrouille")._physics_process(2.0)
	await wait_physics_frames(5)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "Au travail il ne doit pas y avoir de game over")


func test_quitter_le_travail_devant_le_manager_qui_patrouille_declenche_le_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_desk_behind_manager(level)

	level._unhandled_input(_pressed("work"))
	level.get_node("ManagerPatrouille")._physics_process(2.0)
	await wait_physics_frames(5)
	level._unhandled_input(_pressed("work"))
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Hors du travail le joueur doit etre repere")


func test_le_joueur_au_centre_est_repere_quand_le_manager_y_regarde() -> void:
	var level: Node = add_child_autofree(_load_level())
	var manager: Node2D = level.get_node("Manager")

	level.get_node("Player").position = manager.position
	await wait_physics_frames(5)
	assert_false(level.get_node("Interface/MessageGameOver").visible, "Le manager regarde a gauche, pas au centre")

	manager._physics_process(ManagerWatch.SECTOR_DURATION)
	await wait_physics_frames(5)
	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le manager regarde au centre : game over")


func test_le_joueur_dans_la_zone_gauche_passe_quand_le_manager_est_de_dos() -> void:
	var level := _add_level_with_fixed_manager_back()
	var player: CharacterBody2D = level.get_node("Player")

	player.position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "De dos il ne doit pas y avoir de game over")
	assert_true(player.is_physics_processing(), "Le joueur doit pouvoir continuer")


func test_la_victoire_arrete_le_manager_qui_patrouille() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	assert_false(level.get_node("ManagerPatrouille").is_physics_processing(), "Le manager doit s'arreter a la victoire")


# Contact : demi-largeur de la porte (20) + demi-largeur du joueur (16), avec une marge
const DOOR_CONTACT_OFFSET := -40.0


# Met le manager de dos et place le joueur sur la cle, sans appuyer sur E
func _place_player_on_key_behind_manager(level: Node) -> void:
	level.get_node("Manager")._physics_process(ManagerWatch.FACING_DURATION)
	level.get_node("Player").position = level.get_node("Cle").position
	await wait_physics_frames(5)


func _place_player_at_door(level: Node) -> void:
	var player: CharacterBody2D = level.get_node("Player")
	player.position = Vector2(level.get_node("Porte").position.x + DOOR_CONTACT_OFFSET, player.position.y)
	await wait_physics_frames(5)


func _move_right_for(frames: int) -> void:
	Input.action_press("move_right")
	await wait_physics_frames(frames)
	Input.action_release("move_right")


func test_la_porte_est_entre_la_zone_du_manager_et_l_arrivee() -> void:
	var level := _instantiate_level()
	var door: Node2D = level.get_node_or_null("Porte")
	var manager: Node2D = level.get_node("Manager")
	var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0

	assert_true(door is StaticBody2D, "Le niveau doit contenir une porte qui bloque")
	assert_gt(door.position.x, manager.position.x + half_zone, "La porte doit etre apres la zone du manager")
	assert_lt(door.position.x, level.get_node("Arrivee").position.x, "La porte doit etre avant l'arrivee")


func test_la_cle_est_sur_le_bureau_de_gauche() -> void:
	var level := _instantiate_level()
	var key: Node2D = level.get_node_or_null("Cle")
	assert_true(key is Area2D, "Le niveau doit contenir une cle")
	assert_eq(key.position, level.get_node("Bureaux/Bureau1").position, "La cle doit etre sur le bureau de gauche")


func test_la_cle_est_dessinee_devant_les_bureaux() -> void:
	var level := _instantiate_level()
	assert_gt(level.get_node("Cle").get_index(), level.get_node("Bureaux").get_index(), "La cle doit etre devant le bureau")


func test_l_indicateur_de_cle_est_cache_au_depart() -> void:
	var indicator: Label = _instantiate_level().get_node("Interface/IndicateurCle")
	assert_false(indicator.visible, "L'indicateur de cle doit etre cache au depart")
	assert_string_contains(indicator.text, "Key")


func test_e_sur_la_cle_la_prend_sans_travailler() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_key_behind_manager(level)

	level._unhandled_input(_pressed("work"))

	assert_true(level.get_node("Interface/IndicateurCle").visible, "L'indicateur doit s'afficher")
	assert_false(level.get_node("Cle").visible, "La cle doit disparaitre du bureau")
	assert_false(level.get_node("Player").is_working(), "Prendre la cle ne doit pas faire travailler")


func test_un_second_e_sur_le_bureau_de_la_cle_fait_travailler() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_key_behind_manager(level)

	level._unhandled_input(_pressed("work"))
	level._unhandled_input(_pressed("work"))

	assert_true(level.get_node("Player").is_working(), "Le second appui doit faire travailler")
	assert_true(level.get_node("Interface/IndicateurCle").visible, "Le joueur doit garder la cle")


func test_la_porte_fermee_bloque_le_joueur() -> void:
	var level := _add_level_with_fixed_manager_back()
	var player: CharacterBody2D = level.get_node("Player")
	var door: Node2D = level.get_node("Porte")

	player.position.x = door.position.x - 100.0
	await _move_right_for(30)

	assert_lt(player.position.x, door.position.x, "Le joueur ne doit pas traverser la porte fermee")


func test_e_a_la_porte_sans_cle_ne_fait_rien() -> void:
	var level := _add_level_with_fixed_manager_back()
	await _place_player_at_door(level)

	level._unhandled_input(_pressed("work"))
	await wait_physics_frames(2)

	var door: Node2D = level.get_node("Porte")
	assert_true(door.visible, "La porte doit rester visible")
	assert_false(door.get_node("CollisionShape2D").disabled, "La porte doit rester fermee")


func test_e_a_la_porte_avec_la_cle_l_ouvre() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_key_behind_manager(level)
	level._unhandled_input(_pressed("work"))
	await _place_player_at_door(level)

	level._unhandled_input(_pressed("work"))
	await wait_physics_frames(2)

	var door: Node2D = level.get_node("Porte")
	assert_false(door.visible, "La porte ouverte doit disparaitre")
	assert_true(door.get_node("CollisionShape2D").disabled, "La porte ouverte ne doit plus bloquer")
	assert_false(level.get_node("Interface/IndicateurCle").visible, "La cle doit etre consommee")
	assert_false(level.get_node("Player").is_working(), "Ouvrir la porte ne doit pas faire travailler")


func test_la_porte_ouverte_laisse_passer_le_joueur() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _place_player_on_key_behind_manager(level)
	level._unhandled_input(_pressed("work"))
	await _place_player_at_door(level)
	level._unhandled_input(_pressed("work"))
	await wait_physics_frames(2)

	var player: CharacterBody2D = level.get_node("Player")
	await _move_right_for(30)

	assert_gt(player.position.x, level.get_node("Porte").position.x, "Le joueur doit traverser la porte ouverte")
