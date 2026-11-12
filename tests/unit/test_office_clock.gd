extends GutTest


func test_trois_heures() -> void:
	var angles := OfficeClock.hand_angles(3, 0, 0)
	assert_almost_eq(angles.x, PI / 2.0, 0.0001, "A 3 h, l'aiguille des heures est a un quart de tour")
	assert_almost_eq(angles.y, 0.0, 0.0001)
	assert_almost_eq(angles.z, 0.0, 0.0001)


func test_six_heures_et_demie() -> void:
	var angles := OfficeClock.hand_angles(6, 30, 0)
	assert_almost_eq(angles.x, 6.5 / 12.0 * TAU, 0.0001, "L'aiguille des heures avance avec les minutes")
	assert_almost_eq(angles.y, PI, 0.0001, "A la demie, l'aiguille des minutes est en bas")


func test_l_horloge_affiche_douze_heures() -> void:
	assert_almost_eq(OfficeClock.hand_angles(15, 0, 0).x, OfficeClock.hand_angles(3, 0, 0).x, 0.0001, "15 h et 3 h ont la meme aiguille")


func test_la_trotteuse() -> void:
	assert_almost_eq(OfficeClock.hand_angles(0, 0, 45).z, 0.75 * TAU, 0.0001, "A 45 s, la trotteuse est a trois quarts de tour")


func test_set_time_memorise_l_heure() -> void:
	var clock: OfficeClock = autofree(OfficeClock.new())
	clock.set_time(10, 42, 7)
	assert_eq(clock.displayed_time(), Vector3i(10, 42, 7))
