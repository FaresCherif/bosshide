extends GutTest

const A := InteractionHint.Action


func _state(overrides: Dictionary) -> Dictionary:
	var state := {
		"can_act": true, "at_keypad": false, "on_post_it": false, "at_door": false,
		"door_open": false, "has_key": false, "on_key": false, "working": false, "on_desk": false,
	}
	state.merge(overrides, true)
	return state


func test_rien_a_portee() -> void:
	assert_eq(InteractionHint.resolve(_state({})), A.NONE)


func test_le_digicode_passe_avant_tout() -> void:
	assert_eq(InteractionHint.resolve(_state({"at_keypad": true, "on_post_it": true, "on_desk": true})), A.TYPE_CODE)


func test_le_post_it_passe_avant_la_porte_et_le_bureau() -> void:
	assert_eq(InteractionHint.resolve(_state({"on_post_it": true, "on_desk": true})), A.READ_CODE)


func test_la_porte_s_ouvre_avec_la_cle() -> void:
	assert_eq(InteractionHint.resolve(_state({"at_door": true, "has_key": true})), A.OPEN_DOOR)


func test_la_porte_est_verrouillee_sans_la_cle() -> void:
	assert_eq(InteractionHint.resolve(_state({"at_door": true})), A.LOCKED_DOOR)


func test_une_porte_ouverte_n_est_plus_une_interaction() -> void:
	assert_eq(InteractionHint.resolve(_state({"at_door": true, "door_open": true, "has_key": true})), A.NONE)
	assert_eq(InteractionHint.resolve(_state({"at_door": true, "door_open": true})), A.NONE)


func test_la_cle_se_prend_avant_de_travailler() -> void:
	assert_eq(InteractionHint.resolve(_state({"on_key": true, "on_desk": true})), A.TAKE_KEY)


func test_le_bureau() -> void:
	assert_eq(InteractionHint.resolve(_state({"on_desk": true})), A.WORK)
	assert_eq(InteractionHint.resolve(_state({"on_desk": true, "working": true})), A.STOP_WORK)


func test_rien_quand_le_joueur_ne_peut_pas_agir() -> void:
	assert_eq(InteractionHint.resolve(_state({"can_act": false, "on_desk": true, "at_keypad": true})), A.NONE)


func test_les_libelles() -> void:
	assert_eq(InteractionHint.label(A.TYPE_CODE), "E: type the code")
	assert_eq(InteractionHint.label(A.READ_CODE), "E: read the post-it")
	assert_eq(InteractionHint.label(A.OPEN_DOOR), "E: open the door")
	assert_eq(InteractionHint.label(A.LOCKED_DOOR), "Locked - find the key")
	assert_eq(InteractionHint.label(A.TAKE_KEY), "E: grab the key")
	assert_eq(InteractionHint.label(A.WORK), "E: pretend to work")
	assert_eq(InteractionHint.label(A.STOP_WORK), "E: stop pretending")
	assert_eq(InteractionHint.label(A.NONE), "")
