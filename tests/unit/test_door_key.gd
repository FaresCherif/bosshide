extends GutTest


func test_au_depart_la_cle_est_sur_le_bureau_et_la_porte_fermee() -> void:
	var door_key := DoorKey.new()
	assert_true(door_key.is_key_on_desk(), "La cle doit etre sur le bureau au depart")
	assert_false(door_key.has_key(), "Le joueur ne doit pas avoir la cle au depart")
	assert_false(door_key.is_door_open(), "La porte doit etre fermee au depart")


func test_prendre_la_cle() -> void:
	var door_key := DoorKey.new()
	assert_true(door_key.take_key(), "La cle doit pouvoir etre prise")
	assert_false(door_key.is_key_on_desk(), "La cle ne doit plus etre sur le bureau")
	assert_true(door_key.has_key(), "Le joueur doit avoir la cle")


func test_la_cle_ne_se_prend_qu_une_fois() -> void:
	var door_key := DoorKey.new()
	door_key.take_key()
	assert_false(door_key.take_key(), "La cle ne doit pas etre prise deux fois")
	assert_true(door_key.has_key(), "Le joueur doit garder la cle")


func test_la_porte_ne_s_ouvre_pas_sans_cle() -> void:
	var door_key := DoorKey.new()
	assert_false(door_key.open_door(), "La porte ne doit pas s'ouvrir sans cle")
	assert_false(door_key.is_door_open(), "La porte doit rester fermee")


func test_ouvrir_la_porte_consomme_la_cle() -> void:
	var door_key := DoorKey.new()
	door_key.take_key()
	assert_true(door_key.open_door(), "La porte doit s'ouvrir avec la cle")
	assert_true(door_key.is_door_open(), "La porte doit etre ouverte")
	assert_false(door_key.has_key(), "La cle doit etre consommee")


func test_la_porte_ouverte_ne_se_rouvre_pas() -> void:
	var door_key := DoorKey.new()
	door_key.take_key()
	door_key.open_door()
	assert_false(door_key.open_door(), "Une porte deja ouverte ne doit pas se rouvrir")


func test_interagir_sur_la_cle_la_prend() -> void:
	var door_key := DoorKey.new()
	assert_true(door_key.interact(false, true), "L'appui doit etre consomme par la prise de cle")
	assert_true(door_key.has_key(), "Le joueur doit avoir la cle")


func test_interagir_sur_le_bureau_vide_n_est_pas_consomme() -> void:
	var door_key := DoorKey.new()
	door_key.take_key()
	assert_false(door_key.interact(false, true), "Sans cle sur le bureau, l'appui doit servir a travailler")


func test_interagir_a_la_porte_avec_la_cle_l_ouvre() -> void:
	var door_key := DoorKey.new()
	door_key.take_key()
	assert_true(door_key.interact(true, false), "L'appui doit etre consomme par l'ouverture")
	assert_true(door_key.is_door_open(), "La porte doit etre ouverte")


func test_interagir_a_la_porte_sans_cle_n_est_pas_consomme() -> void:
	var door_key := DoorKey.new()
	assert_false(door_key.interact(true, false), "Sans cle l'appui a la porte ne fait rien")
	assert_false(door_key.is_door_open(), "La porte doit rester fermee")


func test_interagir_ailleurs_n_est_pas_consomme() -> void:
	var door_key := DoorKey.new()
	assert_false(door_key.interact(false, false), "Loin de la cle et de la porte, l'appui n'est pas consomme")
	assert_true(door_key.is_key_on_desk(), "La cle doit rester sur le bureau")
