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
