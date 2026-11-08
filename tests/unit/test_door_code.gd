extends GutTest

const CODE := "4721"


func _type(door_code: DoorCode, digits: String) -> void:
	for digit in digits:
		door_code.type_digit(int(digit))


func _rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_le_code_au_hasard_a_quatre_chiffres() -> void:
	for seed_value in range(20):
		var code := DoorCode.random_code(_rng(seed_value))
		assert_eq(code.length(), 4, "Le code doit avoir 4 chiffres")
		assert_true(code.is_valid_int(), "Le code ne doit contenir que des chiffres")


func test_le_code_au_hasard_depend_de_la_graine() -> void:
	assert_eq(DoorCode.random_code(_rng(7)), DoorCode.random_code(_rng(7)), "Meme graine, meme code")


func test_au_depart_rien_n_est_affiche_et_la_porte_est_fermee() -> void:
	var door_code := DoorCode.new(CODE)
	assert_eq(door_code.code(), CODE)
	assert_false(door_code.is_code_shown(), "Le code doit etre cache au depart")
	assert_false(door_code.is_keypad_open(), "Le panneau doit etre ferme au depart")
	assert_false(door_code.is_door_open(), "La porte doit etre fermee au depart")


func test_lire_puis_s_eloigner() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.read()
	assert_true(door_code.is_code_shown(), "Le code doit s'afficher a la lecture")
	door_code.stop_reading()
	assert_false(door_code.is_code_shown(), "Le code doit se cacher quand le joueur part")


func test_ouvrir_et_fermer_le_panneau() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	assert_true(door_code.is_keypad_open(), "Le panneau doit s'ouvrir")
	door_code.close_keypad()
	assert_false(door_code.is_keypad_open(), "Le panneau doit se fermer")


func test_la_saisie_est_limitee_a_quatre_chiffres() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, "123456")
	assert_eq(door_code.entry(), "1234", "La saisie doit s'arreter a 4 chiffres")


func test_la_saisie_demande_le_panneau_ouvert() -> void:
	var door_code := DoorCode.new(CODE)
	_type(door_code, "12")
	assert_eq(door_code.entry(), "", "Sans panneau, rien ne doit etre saisi")


func test_effacer_retire_le_dernier_chiffre() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, "123")
	door_code.erase()
	assert_eq(door_code.entry(), "12", "Le dernier chiffre doit etre efface")
	door_code.erase()
	door_code.erase()
	door_code.erase()
	assert_eq(door_code.entry(), "", "Effacer une saisie vide ne doit rien casser")


func test_fermer_le_panneau_efface_la_saisie() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, "12")
	door_code.close_keypad()
	door_code.open_keypad()
	assert_eq(door_code.entry(), "", "La saisie doit repartir de zero")


func test_une_saisie_incomplete_est_ignoree() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, "47")
	assert_eq(door_code.submit(), DoorCode.Result.IGNORED, "Une saisie incomplete doit etre ignoree")
	assert_eq(door_code.entry(), "47", "La saisie doit etre conservee")


func test_un_mauvais_code_efface_la_saisie() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, "1111")
	assert_eq(door_code.submit(), DoorCode.Result.WRONG, "Le code doit etre refuse")
	assert_eq(door_code.entry(), "", "La saisie doit etre effacee")
	assert_true(door_code.is_keypad_open(), "Le panneau doit rester ouvert")
	assert_false(door_code.is_door_open(), "La porte doit rester fermee")


func test_le_bon_code_ouvre_la_porte() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, CODE)
	assert_eq(door_code.submit(), DoorCode.Result.RIGHT, "Le code doit etre accepte")
	assert_true(door_code.is_door_open(), "La porte doit s'ouvrir")
	assert_false(door_code.is_keypad_open(), "Le panneau doit se fermer")


func test_le_panneau_ne_s_ouvre_plus_porte_ouverte() -> void:
	var door_code := DoorCode.new(CODE)
	door_code.open_keypad()
	_type(door_code, CODE)
	door_code.submit()
	door_code.open_keypad()
	assert_false(door_code.is_keypad_open(), "Porte ouverte, le panneau ne doit plus s'ouvrir")


func test_un_code_avec_des_zeros_fonctionne() -> void:
	var door_code := DoorCode.new("0070")
	door_code.open_keypad()
	_type(door_code, "0070")
	assert_eq(door_code.submit(), DoorCode.Result.RIGHT, "Les zeros doivent compter")
