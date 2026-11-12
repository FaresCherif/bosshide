extends GutTest

const LEVEL_PATH := "res://levels/level_01.tscn"
const MAIN_SCENE_PATH := "res://Game.tscn"
const LEFT_SECTOR_OFFSET := Vector2(-200, 0)


func _load_level() -> Node:
	var scene: PackedScene = load(LEVEL_PATH)
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
	var message: Control = _instantiate_level().get_node("Interface/MessageSucces")
	assert_false(message.visible, "Le message de succes doit etre cache au depart")
	assert_string_contains(message.get_node("Titre").text, "You reached the toilets.")


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
	var message: Control = _instantiate_level().get_node("Interface/MessageGameOver")
	assert_false(message.visible, "Le message de game over doit etre cache au depart")
	assert_eq(message.get_node("Titre").text, "BUSTED!")


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


func test_le_chrono_affiche_zero_au_depart() -> void:
	var chrono: Label = _instantiate_level().get_node_or_null("Interface/Chrono")
	assert_not_null(chrono, "Le niveau doit afficher un chrono")
	assert_eq(chrono.text, "00:00.0", "Le chrono doit partir de zero")


func test_le_chrono_avance_pendant_le_jeu() -> void:
	var level: Node = add_child_autofree(_load_level())
	await wait_physics_frames(10)
	assert_ne(level.get_node("Interface/Chrono").text, "00:00.0", "Le chrono doit avancer")


func test_le_chrono_s_arrete_a_l_arrivee() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	var text: String = level.get_node("Interface/Chrono").text

	await wait_physics_frames(10)

	assert_eq(level.get_node("Interface/Chrono").text, text, "Le chrono doit s'arreter a l'arrivee")


func test_le_chrono_s_arrete_au_game_over() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)
	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le joueur doit etre repere")
	var text: String = level.get_node("Interface/Chrono").text

	await wait_physics_frames(10)

	assert_eq(level.get_node("Interface/Chrono").text, text, "Le chrono doit s'arreter au game over")


func test_le_message_de_succes_affiche_le_temps_et_le_score() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)

	var message: Control = level.get_node("Interface/MessageSucces")
	assert_string_contains(message.get_node("Titre").text, "You reached the toilets.")
	assert_string_contains(message.get_node("Details").text, "Time: " + level.get_node("Interface/Chrono").text)
	assert_string_contains(message.get_node("Details").text, "Score: ")


func test_le_message_de_game_over_n_affiche_pas_de_score() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	var message: Control = level.get_node("Interface/MessageGameOver")
	assert_true(message.visible, "Le joueur doit etre repere")
	assert_string_contains(message.get_node("Details").text, "Time: " + level.get_node("Interface/Chrono").text)
	assert_false(message.get_node("Details").text.contains("Score"), "Le game over ne doit pas afficher de score")


func _digit_key(digit: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_0 + digit
	event.keycode = KEY_0 + digit
	event.pressed = true
	return event


func _type_code(level: Node, code: String) -> void:
	for digit in code:
		level._unhandled_input(_digit_key(int(digit)))


func _wrong_code(code: String) -> String:
	return str((int(code[0]) + 1) % 10) + code.substr(1)


func _open_keypad(level: Node) -> void:
	var player: CharacterBody2D = level.get_node("Player")
	player.position.x = level.get_node("PorteDigicode").position.x + DOOR_CONTACT_OFFSET
	await wait_physics_frames(5)
	level._unhandled_input(_pressed("work"))


func _move_left_for(frames: int) -> void:
	Input.action_press("move_left")
	await wait_physics_frames(frames)
	Input.action_release("move_left")


func test_le_post_it_et_le_digicode_sont_avant_la_zone_du_manager() -> void:
	var level := _instantiate_level()
	var post_it: Node2D = level.get_node_or_null("PostIt")
	var code_door: Node2D = level.get_node_or_null("PorteDigicode")
	var manager: Node2D = level.get_node("Manager")
	var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0

	assert_true(post_it is Area2D, "Le niveau doit contenir un post-it")
	assert_true(code_door is StaticBody2D, "Le niveau doit contenir une porte a digicode")
	assert_gt(post_it.position.x, level.get_node("Player").position.x, "Le post-it doit etre apres le depart")
	assert_lt(post_it.position.x, code_door.position.x, "Le post-it doit etre avant le digicode")
	assert_lt(code_door.position.x, manager.position.x - half_zone, "Le digicode doit etre avant la zone du manager")


func test_le_signal_de_sortie_du_post_it_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var post_it: Area2D = level.get_node("PostIt")
	assert_true(post_it.body_exited.is_connected(level._on_post_it_body_exited), "Le post-it doit prevenir le niveau")


func test_le_code_et_le_panneau_sont_caches_au_depart() -> void:
	var level := _instantiate_level()
	assert_false(level.get_node("PostIt/Code").visible, "Le code doit etre cache au depart")
	assert_false(level.get_node("Interface/Digicode").visible, "Le panneau doit etre cache au depart")


func test_e_sur_le_post_it_affiche_le_code() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position.x = level.get_node("PostIt").position.x
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("work"))

	var code_label: Label = level.get_node("PostIt/Code")
	assert_true(code_label.visible, "Le code doit s'afficher")
	assert_eq(code_label.text, level._door_code.code(), "Le post-it doit afficher le code de la porte")


func test_le_code_se_cache_quand_le_joueur_s_eloigne() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	player.position.x = level.get_node("PostIt").position.x
	await wait_physics_frames(5)
	level._unhandled_input(_pressed("work"))

	player.position.x -= 300.0
	await wait_physics_frames(5)

	assert_false(level.get_node("PostIt/Code").visible, "Le code doit se cacher loin du post-it")


func test_e_contre_la_porte_a_digicode_ouvre_le_panneau() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)
	assert_true(level.get_node("Interface/Digicode").visible, "Le panneau doit s'ouvrir")
	assert_false(level.get_node("Player").is_working(), "Le panneau ne doit pas faire travailler")


func test_le_joueur_ne_bouge_pas_pendant_la_saisie() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	await _open_keypad(level)
	var x := player.position.x

	await _move_left_for(10)

	assert_eq(player.position.x, x, "Le joueur doit rester immobile pendant la saisie")


func test_echap_ferme_le_panneau() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	await _open_keypad(level)

	level._unhandled_input(_pressed("ui_cancel"))
	var x := player.position.x
	await _move_left_for(10)

	assert_false(level.get_node("Interface/Digicode").visible, "Echap doit fermer le panneau")
	assert_lt(player.position.x, x, "Le joueur doit pouvoir bouger apres la fermeture")


func test_la_saisie_s_affiche_dans_le_panneau() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)

	_type_code(level, "47")

	assert_eq(level.get_node("Interface/Digicode/Saisie").text, "4 7 _ _", "Les chiffres tapes doivent s'afficher")


func test_le_bon_code_ouvre_la_porte_a_digicode() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)

	_type_code(level, level._door_code.code())
	level._unhandled_input(_pressed("ui_accept"))
	await wait_physics_frames(2)

	var door: Node2D = level.get_node("PorteDigicode")
	assert_false(door.visible, "La porte doit disparaitre")
	assert_true(door.get_node("CollisionShape2D").disabled, "La porte ne doit plus bloquer")
	assert_false(level.get_node("Interface/Digicode").visible, "Le panneau doit se fermer")


func test_un_mauvais_code_coute_des_points_et_attire_la_patrouille() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)
	var score_before: int = level._score.score()

	_type_code(level, _wrong_code(level._door_code.code()))
	level._unhandled_input(_pressed("ui_accept"))

	assert_eq(level._score.score(), score_before - LevelScore.WRONG_CODE_PENALTY, "Le mauvais code doit couter des points")
	assert_true(level.get_node("ManagerPatrouille").is_attracted(), "Le manager doit etre attire")
	assert_true(level.get_node("Interface/Digicode/Erreur").visible, "Le panneau doit signaler l'erreur")
	assert_true(level.get_node("PorteDigicode").visible, "La porte doit rester fermee")


func test_le_manager_attire_va_vers_le_digicode() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)
	_type_code(level, _wrong_code(level._door_code.code()))
	level._unhandled_input(_pressed("ui_accept"))

	var patrol: Node2D = level.get_node("ManagerPatrouille")
	patrol._physics_process(10.0)

	assert_eq(patrol.position.x, level.get_node("PorteDigicode").position.x, "Le manager doit aller au digicode")


func test_le_game_over_ferme_le_panneau() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)

	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le joueur doit etre repere")
	assert_false(level.get_node("Interface/Digicode").visible, "Le panneau doit se fermer au game over")


func _start_talk(level: Node) -> void:
	level.get_node("Player").position.x = level.get_node("Collegue").position.x
	await wait_physics_frames(5)


func _answer_key(level: Node, right: bool) -> InputEventKey:
	var answer: int = level._quiz.question()["answer"]
	var choice := answer if right else (answer + 1) % 3
	return _digit_key(choice + 1)


func test_le_collegue_est_entre_le_digicode_et_le_bureau_de_gauche() -> void:
	var level := _instantiate_level()
	var colleague: Node2D = level.get_node_or_null("Collegue")
	var manager: Node2D = level.get_node("Manager")
	var half_zone: float = manager.get_node("Zone/CollisionShape2D").shape.size.x / 2.0

	assert_true(colleague is Area2D, "Le niveau doit contenir un collegue")
	assert_gt(colleague.position.x, level.get_node("PorteDigicode").position.x, "Le collegue doit etre apres le digicode")
	assert_lt(colleague.position.x, level.get_node("Bureaux/Bureau1").position.x, "Le collegue doit etre avant le bureau de gauche")
	assert_gt(colleague.position.x, manager.position.x - half_zone, "Le collegue doit etre dans la zone du manager")


func test_le_collegue_est_dessine_derriere_le_joueur() -> void:
	var level := _instantiate_level()
	assert_lt(level.get_node("Collegue").get_index(), level.get_node("Player").get_index(), "Le collegue doit etre derriere le joueur")


func test_le_signal_du_collegue_est_connecte() -> void:
	var level: Node = add_child_autofree(_load_level())
	var colleague: Area2D = level.get_node("Collegue")
	assert_true(colleague.body_entered.is_connected(level._on_collegue_body_entered), "Le collegue doit prevenir le niveau")


func test_le_panneau_du_collegue_est_cache_au_depart() -> void:
	assert_false(_instantiate_level().get_node("Interface/Collegue").visible, "Le panneau doit etre cache au depart")


func test_passer_devant_le_collegue_lance_la_question() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)

	var question: Dictionary = level._quiz.question()
	assert_true(level.get_node("Interface/Collegue").visible, "Le panneau doit s'ouvrir")
	assert_eq(level.get_node("Interface/Collegue/Question").text, question["text"], "La question doit s'afficher")
	assert_string_contains(level.get_node("Interface/Collegue/Choix").text, "1. " + question["choices"][0])


func test_le_joueur_ne_bouge_pas_pendant_la_question() -> void:
	var level: Node = add_child_autofree(_load_level())
	var player: CharacterBody2D = level.get_node("Player")
	await _start_talk(level)
	var x := player.position.x

	await _move_left_for(10)

	assert_eq(player.position.x, x, "Le joueur doit rester immobile pendant la question")


func test_le_manager_ne_repere_pas_le_joueur_pendant_la_question() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)
	await wait_physics_frames(10)

	assert_false(level.get_node("Interface/MessageGameOver").visible, "Pendant la question le joueur est protege")
	assert_true(level.get_node("Manager").is_physics_processing(), "Le manager doit continuer son cycle")


func test_les_autres_touches_ne_ferment_pas_la_question() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)

	level._unhandled_input(_pressed("work"))
	level._unhandled_input(_pressed("ui_cancel"))
	level._unhandled_input(_digit_key(4))

	assert_true(level.get_node("Interface/Collegue").visible, "Seules les touches 1 a 3 repondent")


func test_la_bonne_reponse_ferme_la_question_sans_penalite() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)
	var score_before: int = level._score.score()

	level._unhandled_input(_answer_key(level, true))

	assert_false(level.get_node("Interface/Collegue").visible, "Le panneau doit se fermer")
	assert_eq(level._score.score(), score_before, "La bonne reponse ne doit rien couter")
	assert_false(level.get_node("ManagerPatrouille").is_attracted(), "Le manager ne doit pas foncer")


func test_une_mauvaise_reponse_coute_des_points_et_fait_foncer_la_patrouille() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)
	var score_before: int = level._score.score()
	var patrol: Node2D = level.get_node("ManagerPatrouille")

	level._unhandled_input(_answer_key(level, false))
	var x_before := patrol.position.x
	patrol._physics_process(0.5)

	assert_false(level.get_node("Interface/Collegue").visible, "Le panneau doit se fermer")
	assert_eq(level._score.score(), score_before - LevelScore.WRONG_ANSWER_PENALTY, "La mauvaise reponse doit couter des points")
	assert_almost_eq(x_before - patrol.position.x, ManagerPatrol.SPEED * ManagerPatrol.RUSH_FACTOR * 0.5, 0.01, "Le manager doit foncer vers le collegue")


func test_apres_une_mauvaise_reponse_le_joueur_n_est_plus_protege() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)

	level._unhandled_input(_answer_key(level, false))
	await wait_physics_frames(5)

	assert_true(level.get_node("Interface/MessageGameOver").visible, "Le manager qui regarde a gauche doit reperer le joueur")


func test_repasser_devant_le_collegue_ne_relance_pas_la_question() -> void:
	var level := _add_level_with_fixed_manager_back()
	var player: CharacterBody2D = level.get_node("Player")
	await _start_talk(level)
	level._unhandled_input(_answer_key(level, true))

	player.position.x -= 100.0
	await wait_physics_frames(5)
	await _start_talk(level)

	assert_false(level.get_node("Interface/Collegue").visible, "Le collegue ne doit parler qu'une fois")
	assert_false(level._quiz.is_talking(), "Le joueur doit pouvoir passer")


func test_action_niveau_suivant_a_sa_touche() -> void:
	assert_true(InputMap.has_action("next_level"), "L'action next_level doit exister")
	assert_has(_action_keycodes("next_level"), KEY_ENTER, "Entree doit passer au niveau suivant")


func test_l_arrivee_emet_la_reussite_avec_le_score() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(level, "succeeded", [level._score.score()])


func test_le_message_de_succes_propose_le_niveau_suivant() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	await wait_frames(2)
	var next: Button = level.get_node("Interface/MessageSucces/Boutons/Suivant")
	assert_true(next.is_visible_in_tree(), "Le bouton du niveau suivant doit s'afficher")
	assert_true(next.has_focus(), "Entree doit activer le bouton du niveau suivant")


func test_r_ne_relance_pas_pendant_le_jeu() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level._unhandled_input(_pressed("restart"))
	assert_signal_not_emitted(level, "restart_requested", "R ne doit rien faire pendant le jeu")


func test_r_apres_la_fin_demande_la_relance() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("restart"))

	assert_signal_emitted(level, "restart_requested", "R apres un game over doit relancer")


func test_entree_apres_la_reussite_demande_le_niveau_suivant() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("next_level"))

	assert_signal_emitted(level, "next_requested", "Entree apres une reussite doit passer au suivant")


func test_entree_apres_un_game_over_ne_passe_pas_au_suivant() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("next_level"))

	assert_signal_not_emitted(level, "next_requested", "Un echec ne doit pas mener au niveau suivant")


func test_echap_pendant_le_jeu_demande_la_pause() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level._unhandled_input(_pressed("ui_cancel"))
	assert_signal_emitted(level, "pause_requested", "Echap pendant le jeu doit mettre en pause")
	assert_signal_not_emitted(level, "menu_requested", "Echap pendant le jeu ne doit plus quitter le niveau")


func test_echap_apres_un_game_over_demande_le_menu() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)

	level._unhandled_input(_pressed("ui_cancel"))

	assert_signal_emitted(level, "menu_requested", "Echap apres un game over doit ramener au selecteur")
	assert_signal_not_emitted(level, "pause_requested", "Apres la fin, il n'y a rien a mettre en pause")


func test_echap_pendant_le_digicode_ferme_seulement_le_panneau() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)
	watch_signals(level)

	level._unhandled_input(_pressed("ui_cancel"))

	assert_false(level.get_node("Interface/Digicode").visible, "Echap doit fermer le panneau")
	assert_signal_not_emitted(level, "menu_requested", "Echap ne doit pas quitter le niveau pendant le digicode")


func test_echap_pendant_la_question_est_ignore() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _start_talk(level)
	watch_signals(level)

	level._unhandled_input(_pressed("ui_cancel"))

	assert_signal_not_emitted(level, "menu_requested", "Echap ne doit pas quitter le niveau pendant la question")


func test_les_messages_de_fin_mentionnent_echap() -> void:
	var level := _instantiate_level()
	assert_string_contains(level.get_node("Interface/MessageGameOver/Aide").text, "Esc")
	assert_string_contains(level.get_node("Interface/MessageSucces/Aide").text, "Esc")


func _reach_goal(level: Node) -> void:
	level.get_node("Player").position = level.get_node("Arrivee").position
	await wait_physics_frames(5)
	await wait_frames(2)


func _get_spotted(level: Node) -> void:
	level.get_node("Player").position = level.get_node("Manager").position + LEFT_SECTOR_OFFSET
	await wait_physics_frames(5)
	await wait_frames(2)


func test_l_ecran_de_reussite_propose_trois_boutons() -> void:
	var screen: Control = _instantiate_level().get_node("Interface/MessageSucces")
	assert_eq(screen.get_node("Boutons/Suivant").text, "Next mission")
	assert_eq(screen.get_node("Boutons/Rejouer").text, "Redo it (unpaid)")
	assert_eq(screen.get_node("Boutons/Selection").text, "Mission list")


func test_l_ecran_de_game_over_propose_rejouer_et_la_selection() -> void:
	var screen: Control = _instantiate_level().get_node("Interface/MessageGameOver")
	assert_eq(screen.get_node("Boutons").get_child_count(), 2, "Le game over n'a pas de bouton suivant")
	assert_eq(screen.get_node("Boutons/Rejouer").text, "Try again")
	assert_eq(screen.get_node("Boutons/Selection").text, "Mission list")


func test_les_boutons_de_reussite_emettent_les_signaux() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Interface/MessageSucces/Boutons/Suivant").pressed.emit()
	level.get_node("Interface/MessageSucces/Boutons/Rejouer").pressed.emit()
	level.get_node("Interface/MessageSucces/Boutons/Selection").pressed.emit()
	assert_signal_emitted(level, "next_requested", "Next doit passer au niveau suivant")
	assert_signal_emitted(level, "restart_requested", "Replay doit relancer le niveau")
	assert_signal_emitted(level, "menu_requested", "Level select doit ramener au selecteur")


func test_les_boutons_de_game_over_emettent_les_signaux() -> void:
	var level: Node = add_child_autofree(_load_level())
	watch_signals(level)
	level.get_node("Interface/MessageGameOver/Boutons/Rejouer").pressed.emit()
	level.get_node("Interface/MessageGameOver/Boutons/Selection").pressed.emit()
	assert_signal_emitted(level, "restart_requested", "Replay doit relancer le niveau")
	assert_signal_emitted(level, "menu_requested", "Level select doit ramener au selecteur")


func test_apres_un_game_over_rejouer_a_le_focus() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _get_spotted(level)
	var replay: Button = level.get_node("Interface/MessageGameOver/Boutons/Rejouer")
	assert_true(replay.is_visible_in_tree(), "Le bouton rejouer doit s'afficher")
	assert_true(replay.has_focus(), "Entree doit activer le bouton rejouer")


func test_l_ecran_de_reussite_affiche_le_numero_du_niveau() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.configure(4, false)
	assert_string_contains(level.get_node("Interface/MessageSucces/Titre").text, "Level 4 complete!")
	assert_eq(level.get_node("Interface/MessageSucces/Boutons/Suivant").text, "Next mission")


func test_au_dernier_niveau_le_bouton_suivant_devient_finish() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.configure(2, true)
	assert_eq(level.get_node("Interface/MessageSucces/Boutons/Suivant").text, "Clock out")


func test_le_meilleur_score_est_cache_tant_que_le_jeu_ne_l_a_pas_donne() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _reach_goal(level)
	assert_false(level.get_node("Interface/MessageSucces/Record").visible, "Sans le jeu, aucun meilleur score n'est connu")


func test_le_meilleur_score_s_affiche_avec_le_record() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.show_best(780, true)
	var record: Label = level.get_node("Interface/MessageSucces/Record")
	assert_true(record.visible, "Le meilleur score doit s'afficher")
	assert_eq(record.text, "New best! Best: 780")


func test_la_reussite_affiche_la_plaque_vacant_et_le_rang() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _reach_goal(level)
	var screen: Control = level.get_node("Interface/MessageSucces")
	assert_eq(screen.get_node("Plaque").text, "VACANT")
	assert_eq(screen.get_node("Rang").text, LevelResult.rank_line(level._score.score()), "Le rang doit suivre le score")


func test_le_game_over_explique_ou_le_joueur_va_finir() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _get_spotted(level)
	assert_eq(level.get_node("Interface/MessageGameOver/SousTitre").text, "The boss saw you. His office. Now.")


func test_les_textes_du_niveau_restent_lisibles_sur_le_decor() -> void:
	var level := _instantiate_level()
	for path in ["Interface/Chrono", "Interface/IndicateurCle", "PostIt/Code"]:
		assert_eq(level.get_node(path).theme_type_variation, &"HudLabel", path + " doit etre en blanc avec contour")


# En headless la fenetre est minuscule : on place la scene dans un viewport a la taille du jeu
func _screen_size() -> Vector2i:
	return Vector2i(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))


func _add_in_game_viewport(node: Node) -> Node:
	var viewport: SubViewport = add_child_autofree(SubViewport.new())
	viewport.size = _screen_size()
	viewport.add_child(node)
	return node


func _assert_inside_screen(screen: Control) -> void:
	var bounds := Rect2(Vector2.ZERO, Vector2(_screen_size()))
	for node in screen.find_children("*", "Control", true, false):
		var control := node as Control
		if control.is_visible_in_tree():
			assert_true(bounds.encloses(control.get_global_rect()), "%s doit rester dans l'ecran : %s" % [control.name, control.get_global_rect()])


func test_les_ecrans_de_fin_tiennent_dans_l_ecran() -> void:
	var level: Node = _add_in_game_viewport(_load_level())
	for path in ["Interface/MessageSucces", "Interface/MessageGameOver"]:
		var screen: Control = level.get_node(path)
		screen.visible = true
		if screen.has_node("Record"):
			screen.get_node("Record").visible = true
		await wait_frames(2)
		_assert_inside_screen(screen)
		screen.visible = false


func test_le_tampon_busted_reste_dans_la_fiche() -> void:
	var level: Node = _add_in_game_viewport(_load_level())
	var screen: Control = level.get_node("Interface/MessageGameOver")
	screen.visible = true
	await wait_frames(2)
	var stamp: Control = screen.get_node("Titre")
	var tween := UiFx.stamp(stamp, level.STAMP_ANGLE)
	await tween.finished
	var sheet := (screen.get_node("Fiche") as Control).get_global_rect()
	var transform := stamp.get_global_transform()
	for corner in [Vector2.ZERO, Vector2(stamp.size.x, 0), stamp.size, Vector2(0, stamp.size.y)]:
		var point: Vector2 = transform * corner
		assert_true(sheet.has_point(point), "Le coin %s du tampon penche doit rester dans la fiche %s" % [point, sheet])


func test_le_game_over_est_une_note_beige_signee_du_patron() -> void:
	var screen: Control = _instantiate_level().get_node("Interface/MessageGameOver")
	var sheet: Panel = screen.get_node("Fiche")
	assert_eq(sheet.theme_type_variation, &"", "La fiche du game over doit etre la note beige du theme")
	assert_eq(sheet.rotation, 0.0, "La note beige doit etre droite")
	for name in ["Tableau", "Punaise", "Fiche/Lignes", "Scotch"]:
		assert_null(screen.get_node_or_null(name), "Le game over ne doit plus avoir de " + name)
	assert_eq(screen.get_node("Signature").text, "- The Boss")
	for button in screen.get_node("Boutons").get_children():
		assert_eq(button.theme_type_variation, &"", "%s doit reprendre le post-it du theme" % button.name)


func _spot_with(level: Node, manager_name: String) -> void:
	level.get_node(manager_name).body_spotted.emit(level.get_node("Player"))
	await wait_frames(2)


func _form(level: Node) -> String:
	return level.get_node("Interface/MessageGameOver/Formulaire").text


func test_le_formulaire_dit_quel_manager_a_repere_le_joueur() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _spot_with(level, "ManagerPatrouille")
	assert_string_contains(_form(level), "[X] The boss (patrolling)")
	assert_string_contains(_form(level), "[  ] The boss (watching)")


func test_le_formulaire_coche_le_manager_fixe() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _spot_with(level, "Manager")
	assert_string_contains(_form(level), "[X] The boss (watching)")


func test_la_cle_en_poche_est_un_motif() -> void:
	var level: Node = add_child_autofree(_load_level())
	level._door_key.take_key()
	await _spot_with(level, "Manager")
	assert_string_contains(_form(level), "[X] In possession of a stolen key")
	assert_string_contains(_form(level), "[  ] Knows confidential codes")


func test_un_mauvais_code_apparait_dans_les_statistiques() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _open_keypad(level)
	_type_code(level, _wrong_code(level._door_code.code()))
	level._unhandled_input(_pressed("ui_accept"))
	await _spot_with(level, "Manager")
	assert_string_contains(level.get_node("Interface/MessageGameOver/Details").text, "Wrong codes: 1 - Wrong answers: 0")


func test_la_sanction_depend_du_niveau() -> void:
	var level: Node = add_child_autofree(_load_level())
	level.configure(2, false)
	await _spot_with(level, "Manager")
	assert_string_contains(_form(level), "Sanction: " + HrWarning.sanction(2))


func test_le_game_over_a_une_capture_de_surveillance() -> void:
	var level: Node = add_child_autofree(_load_level())
	await _spot_with(level, "Manager")
	var photo: TextureRect = level.get_node("Interface/MessageGameOver/Photo")
	var no_signal: Label = photo.get_node("PasDeSignal")
	assert_true(photo.texture != null or no_signal.visible, "La photo doit montrer la capture, ou NO SIGNAL sans rendu")
	assert_eq(photo.get_node("Legende").text, SurveillanceShot.caption(level.get_node("Interface/Chrono").text))
	assert_true(photo.material is ShaderMaterial, "La capture doit avoir le look camera de surveillance")


func test_le_tampon_busted_ne_couvre_pas_les_boutons() -> void:
	var level: Node = _add_in_game_viewport(_load_level())
	var screen: Control = level.get_node("Interface/MessageGameOver")
	screen.visible = true
	await wait_frames(2)
	var stamp: Control = screen.get_node("Titre")
	var tween := UiFx.stamp(stamp, level.STAMP_ANGLE)
	await tween.finished
	var transform := stamp.get_global_transform()
	var stamp_box := Rect2(transform * Vector2.ZERO, Vector2.ZERO)
	for corner in [Vector2(stamp.size.x, 0), stamp.size, Vector2(0, stamp.size.y)]:
		stamp_box = stamp_box.expand(transform * corner)
	# Le contour du focus deborde de 5 px autour des boutons
	var buttons := (screen.get_node("Boutons") as Control).get_global_rect().grow(6.0)
	assert_false(stamp_box.intersects(buttons), "Le tampon %s ne doit pas couvrir les boutons %s" % [stamp_box, buttons])
