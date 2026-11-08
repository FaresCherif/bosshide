extends GutTest

const LEFT_LIMIT := -300.0
const RIGHT_LIMIT := 300.0
const ONE_WAY_DURATION := 4.0


func _new_patrol() -> ManagerPatrol:
	return ManagerPatrol.new(LEFT_LIMIT, RIGHT_LIMIT)


func test_au_depart_le_manager_est_a_la_limite_droite() -> void:
	assert_eq(_new_patrol().get_x(), RIGHT_LIMIT, "Le manager doit demarrer a la limite droite")


func test_au_depart_le_manager_va_vers_la_gauche() -> void:
	assert_eq(_new_patrol().get_direction(), -1, "Le manager doit partir vers la gauche")


func test_le_manager_avance_a_sa_vitesse() -> void:
	var patrol := _new_patrol()
	patrol.update(1.0)
	assert_eq(patrol.get_x(), RIGHT_LIMIT - ManagerPatrol.SPEED, "Le manager doit avancer vers la gauche")


func test_le_manager_fait_demi_tour_a_la_limite_gauche() -> void:
	var patrol := _new_patrol()
	patrol.update(ONE_WAY_DURATION + 0.5)
	assert_eq(patrol.get_direction(), 1, "Le manager doit repartir vers la droite")
	assert_eq(patrol.get_x(), LEFT_LIMIT + ManagerPatrol.SPEED * 0.5, "Le trop-parcouru doit etre reporte")


func test_le_manager_fait_demi_tour_a_la_limite_droite() -> void:
	var patrol := _new_patrol()
	patrol.update(ONE_WAY_DURATION + 0.5)
	patrol.update(ONE_WAY_DURATION)
	assert_eq(patrol.get_direction(), -1, "Le manager doit repartir vers la gauche")
	assert_eq(patrol.get_x(), RIGHT_LIMIT - ManagerPatrol.SPEED * 0.5, "Le trop-parcouru doit etre reporte")


func test_un_aller_retour_ramene_le_manager_a_son_depart() -> void:
	var patrol := _new_patrol()
	patrol.update(ONE_WAY_DURATION * 2.0)
	assert_eq(patrol.get_x(), RIGHT_LIMIT, "Le manager doit revenir a la limite droite")


func test_un_grand_delta_reste_dans_les_limites() -> void:
	var patrol := _new_patrol()
	patrol.update(ONE_WAY_DURATION * 5.5)
	assert_between(patrol.get_x(), LEFT_LIMIT, RIGHT_LIMIT, "Le manager doit rester dans ses limites")


func test_attirer_amene_le_manager_a_la_cible_hors_de_ses_limites() -> void:
	var patrol := _new_patrol()
	patrol.attract(-400.0)
	patrol.update(5.0)
	assert_eq(patrol.get_x(), -400.0, "Le manager doit aller jusqu'a la cible")
	assert_eq(patrol.get_direction(), -1, "Le manager doit regarder vers la cible")
	assert_true(patrol.is_attracted(), "Le manager doit etre attire")


func test_attirer_vers_la_droite() -> void:
	var patrol := _new_patrol()
	patrol.attract(500.0)
	patrol.update(2.0)
	assert_eq(patrol.get_x(), 500.0, "Le manager doit aller jusqu'a la cible")
	assert_eq(patrol.get_direction(), 1, "Le manager doit regarder vers la cible")


func test_le_manager_attire_attend_sur_place() -> void:
	var patrol := _new_patrol()
	patrol.attract(-400.0)
	patrol.update(5.0)
	patrol.update(ManagerPatrol.ATTRACT_WAIT - 0.1)
	assert_eq(patrol.get_x(), -400.0, "Le manager doit rester a la cible")
	assert_true(patrol.is_attracted(), "Le manager doit encore etre attire")


func test_le_manager_revient_dans_ses_limites_puis_reprend_sa_ronde() -> void:
	var patrol := _new_patrol()
	patrol.attract(-400.0)
	patrol.update(5.0)
	patrol.update(ManagerPatrol.ATTRACT_WAIT)
	patrol.update(1.0)
	assert_eq(patrol.get_x(), LEFT_LIMIT, "Le manager doit revenir a sa limite")
	assert_eq(patrol.get_direction(), 1, "Le manager doit repartir vers l'interieur")
	assert_false(patrol.is_attracted(), "Le manager doit reprendre sa ronde")

	patrol.update(1.0)
	assert_eq(patrol.get_x(), LEFT_LIMIT + ManagerPatrol.SPEED, "La ronde doit reprendre normalement")


func test_attire_dans_ses_limites_il_reprend_sa_ronde_sur_place() -> void:
	var patrol := _new_patrol()
	patrol.attract(0.0)
	patrol.update(2.0)
	patrol.update(ManagerPatrol.ATTRACT_WAIT)
	assert_false(patrol.is_attracted(), "Le manager doit reprendre sa ronde")
	patrol.update(1.0)
	assert_eq(patrol.get_x(), -ManagerPatrol.SPEED, "La ronde doit reprendre depuis la cible")


func test_une_nouvelle_attirance_remplace_la_cible() -> void:
	var patrol := _new_patrol()
	patrol.attract(-400.0)
	patrol.update(1.0)
	patrol.attract(200.0)
	patrol.update(1.0)
	assert_eq(patrol.get_x(), 200.0, "Le manager doit aller vers la nouvelle cible")
	assert_eq(patrol.get_direction(), 1, "Le manager doit regarder vers la nouvelle cible")
