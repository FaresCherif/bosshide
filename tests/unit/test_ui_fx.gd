extends GutTest


func _add_control() -> Control:
	var control: Control = add_child_autofree(Control.new())
	control.size = Vector2(200, 80)
	return control


func test_pop_in_finit_a_la_taille_normale() -> void:
	var control := _add_control()
	var tween := UiFx.pop_in(control)
	# Godot borne l'echelle a une valeur minuscule au lieu de zero
	assert_almost_eq(control.scale, Vector2.ZERO, Vector2(0.001, 0.001), "Le pop doit partir de rien")
	assert_eq(control.pivot_offset, control.size / 2.0, "Le pop doit grossir depuis le centre")
	await tween.finished
	assert_eq(control.scale, Vector2.ONE, "Le pop doit finir a la taille normale")


func test_stamp_finit_penche_a_la_taille_normale() -> void:
	var control := _add_control()
	var tween := UiFx.stamp(control, -0.15)
	assert_gt(control.scale.x, 1.0, "Le tampon doit partir plus grand")
	await tween.finished
	assert_eq(control.scale, Vector2.ONE, "Le tampon doit finir a la taille normale")
	assert_almost_eq(control.rotation, -0.15, 0.001, "Le tampon doit finir penche")
	assert_eq(control.modulate.a, 1.0, "Le tampon doit finir opaque")


func test_shake_revient_a_sa_place() -> void:
	var control := _add_control()
	control.position = Vector2(40, 30)
	var tween := UiFx.shake(control)
	await tween.finished
	assert_eq(control.position, Vector2(40, 30), "La secousse doit revenir a la position de depart")


func test_wobble_tourne_en_boucle() -> void:
	var control := _add_control()
	var tween := UiFx.wobble(control)
	assert_true(tween.is_valid(), "L'oscillation doit tourner")
	assert_eq(tween.get_loops_left(), -1, "L'oscillation doit boucler sans fin")
	tween.kill()
