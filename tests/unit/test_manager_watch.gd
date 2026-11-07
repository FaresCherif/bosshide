extends GutTest


func test_au_depart_le_manager_est_de_face() -> void:
	var watch := ManagerWatch.new()
	assert_true(watch.is_facing(), "Le manager doit commencer de face")


func test_le_manager_reste_de_face_juste_avant_10_secondes() -> void:
	var watch := ManagerWatch.new()
	watch.update(9.9)
	assert_true(watch.is_facing(), "Le manager doit rester de face pendant 10 secondes")


func test_le_manager_se_retourne_apres_10_secondes() -> void:
	var watch := ManagerWatch.new()
	watch.update(10.0)
	assert_false(watch.is_facing(), "Le manager doit etre de dos apres 10 secondes")


func test_le_manager_reste_de_dos_juste_avant_15_secondes() -> void:
	var watch := ManagerWatch.new()
	watch.update(10.0)
	watch.update(4.9)
	assert_false(watch.is_facing(), "Le manager doit rester de dos pendant 5 secondes")


func test_le_manager_revient_de_face_apres_15_secondes() -> void:
	var watch := ManagerWatch.new()
	watch.update(10.0)
	watch.update(5.0)
	assert_true(watch.is_facing(), "Le manager doit revenir de face apres 5 secondes de dos")


func test_le_cycle_se_repete() -> void:
	var watch := ManagerWatch.new()
	watch.update(15.0)
	watch.update(10.0)
	assert_false(watch.is_facing(), "Le manager doit se retourner a nouveau au deuxieme cycle")


func test_le_temps_en_trop_est_reporte_sur_la_phase_suivante() -> void:
	var watch := ManagerWatch.new()
	watch.update(12.0)
	watch.update(3.0)
	assert_true(watch.is_facing(), "Les 2 secondes en trop doivent compter dans la phase de dos")


func test_un_grand_delta_traverse_plusieurs_phases() -> void:
	var watch := ManagerWatch.new()
	watch.update(26.0)
	assert_false(watch.is_facing(), "A 26 secondes le manager doit etre de dos au deuxieme cycle")


func test_le_balayage_dure_toute_la_phase_de_face() -> void:
	var duration := ManagerWatch.SCAN_ORDER.size() * ManagerWatch.SECTOR_DURATION
	assert_eq(duration, ManagerWatch.FACING_DURATION, "Le balayage doit remplir les 10 secondes de face")


func test_le_manager_balaye_de_gauche_a_droite_puis_de_droite_a_gauche() -> void:
	var watch := ManagerWatch.new()
	for expected in [-1, 0, 1, 0, -1]:
		assert_eq(watch.current_sector(), expected, "Le manager doit suivre l'ordre gauche, centre, droite, centre, gauche")
		watch.update(ManagerWatch.SECTOR_DURATION)


func test_le_manager_reste_sur_une_zone_juste_avant_2_secondes() -> void:
	var watch := ManagerWatch.new()
	watch.update(1.9)
	assert_eq(watch.current_sector(), -1, "Le manager doit rester 2 secondes sur la zone gauche")


func test_le_balayage_recommence_au_cycle_suivant() -> void:
	var watch := ManagerWatch.new()
	watch.update(15.0)
	assert_eq(watch.current_sector(), -1, "Le balayage doit recommencer a gauche")
	watch.update(ManagerWatch.SECTOR_DURATION)
	assert_eq(watch.current_sector(), 0, "Le balayage doit continuer au centre")


func test_les_trois_zones_decoupent_la_largeur() -> void:
	assert_eq(ManagerWatch.sector_at(-150.0, 600.0), -1, "A -150 le corps doit etre dans la zone gauche")
	assert_eq(ManagerWatch.sector_at(-99.0, 600.0), 0, "A -99 le corps doit etre au centre")
	assert_eq(ManagerWatch.sector_at(0.0, 600.0), 0, "A 0 le corps doit etre au centre")
	assert_eq(ManagerWatch.sector_at(99.0, 600.0), 0, "A 99 le corps doit etre au centre")
	assert_eq(ManagerWatch.sector_at(150.0, 600.0), 1, "A 150 le corps doit etre dans la zone droite")


func test_le_manager_voit_la_zone_regardee() -> void:
	var watch := ManagerWatch.new()
	assert_true(watch.sees(-200.0, 600.0), "Le manager doit voir dans la zone regardee")


func test_le_manager_ne_voit_pas_les_autres_zones() -> void:
	var watch := ManagerWatch.new()
	assert_false(watch.sees(0.0, 600.0), "Le manager ne doit pas voir le centre en regardant a gauche")
	assert_false(watch.sees(200.0, 600.0), "Le manager ne doit pas voir la droite en regardant a gauche")


func test_de_dos_le_manager_ne_voit_aucune_zone() -> void:
	var watch := ManagerWatch.new()
	watch.update(ManagerWatch.FACING_DURATION)
	for offset in [-200.0, 0.0, 200.0]:
		assert_false(watch.sees(offset, 600.0), "De dos le manager ne doit rien voir")
