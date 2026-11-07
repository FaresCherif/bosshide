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


func _watch_after(seconds: float) -> ManagerWatch:
	var watch := ManagerWatch.new()
	watch.update(seconds)
	return watch


func test_la_position_du_regard_suit_le_balayage() -> void:
	var expected := {
		1.0: -1.0, 2.0: -0.5, 3.0: 0.0, 4.0: 0.5, 5.0: 1.0, 6.0: 0.5, 7.0: 0.0, 8.0: -0.5, 9.0: -1.0,
	}
	for seconds in expected:
		assert_eq(_watch_after(seconds).look_position(), expected[seconds], "Position du regard a %s secondes" % seconds)


func test_le_regard_attend_a_gauche_au_debut_et_a_la_fin() -> void:
	assert_eq(ManagerWatch.new().look_position(), -1.0, "Le regard doit commencer a gauche")
	assert_eq(_watch_after(0.5).look_position(), -1.0, "Le regard doit attendre a gauche la premiere seconde")
	assert_eq(_watch_after(9.5).look_position(), -1.0, "Le regard doit attendre a gauche la derniere seconde")


func test_le_regard_avance_progressivement() -> void:
	assert_eq(_watch_after(2.5).look_position(), -0.25, "Le regard doit glisser entre deux zones")


func test_le_regard_est_au_milieu_de_chaque_zone_a_mi_etape() -> void:
	for step in ManagerWatch.SCAN_ORDER.size():
		var seconds := (step + 0.5) * ManagerWatch.SECTOR_DURATION
		assert_eq(_watch_after(seconds).look_position(), float(ManagerWatch.SCAN_ORDER[step]), "Le regard doit etre au milieu de la zone")


func test_le_regard_passe_la_limite_quand_la_zone_change() -> void:
	for step in range(1, ManagerWatch.SCAN_ORDER.size()):
		var seconds := step * ManagerWatch.SECTOR_DURATION
		assert_eq(absf(_watch_after(seconds).look_position()), 0.5, "Le regard doit etre sur une limite au changement de zone")


func test_de_dos_le_regard_est_a_gauche() -> void:
	assert_eq(_watch_after(12.0).look_position(), -1.0, "De dos le regard doit etre pret a repartir de la gauche")


func test_la_fleche_est_visible_de_face() -> void:
	assert_true(ManagerWatch.new().is_arrow_visible(), "La fleche doit etre visible de face")


func test_la_fleche_est_cachee_de_dos() -> void:
	assert_false(_watch_after(ManagerWatch.FACING_DURATION).is_arrow_visible(), "La fleche doit etre cachee de dos")
	assert_false(_watch_after(13.5).is_arrow_visible(), "La fleche doit rester cachee 1,5 seconde avant le retournement")


func test_la_fleche_previent_avant_le_retournement() -> void:
	assert_true(_watch_after(14.5).is_arrow_visible(), "La fleche doit reapparaitre juste avant le retournement")
