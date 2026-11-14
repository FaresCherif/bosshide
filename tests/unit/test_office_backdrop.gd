extends GutTest

const COLLEAGUE_GREEN := Color(0.3, 0.7, 0.35, 1)


func _luminance(color: Color) -> float:
	return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b


func test_le_motif_est_toujours_le_meme() -> void:
	assert_eq(OfficeBackdrop.props(), OfficeBackdrop.props(), "Le decor ne doit pas changer")


func test_les_elements_du_mur_tiennent_dans_le_motif_sans_se_chevaucher() -> void:
	var props := OfficeBackdrop.props()
	assert_gt(props.size(), 6, "Le mur doit etre garni")
	for i in props.size():
		var rect: Rect2 = props[i]["rect"]
		assert_gte(rect.position.x, 0.0, "%s doit etre dans le motif" % props[i]["kind"])
		assert_lte(rect.end.x, OfficeBackdrop.TILE_WIDTH, "%s doit etre dans le motif" % props[i]["kind"])
		assert_lte(rect.end.y, OfficeBackdrop.FLOOR_Y, "%s doit etre au-dessus du sol" % props[i]["kind"])
		for j in i:
			assert_false(rect.intersects(props[j]["rect"]), "%s et %s ne doivent pas se chevaucher" % [props[i]["kind"], props[j]["kind"]])


func test_le_decor_reste_sombre_pour_que_le_jeu_ressorte() -> void:
	assert_lt(_luminance(OfficeBackdrop.WALL_COLOR), 0.45, "Le mur doit rester sombre")
	assert_gt(_luminance(COLLEAGUE_GREEN) - _luminance(OfficeBackdrop.PLANT_COLOR), 0.15, "La plante ne doit pas ressembler au collegue")


func test_la_moquette_est_sous_le_sol() -> void:
	assert_gte(OfficeBackdrop.FLOOR_Y, 32.0, "La moquette commence sous le haut du sol")


func test_le_plafond_est_bas_pour_remplir_le_haut_de_l_ecran() -> void:
	assert_gt(OfficeBackdrop.CEILING_Y, -500.0, "Le plafond doit etre assez bas pour ne pas laisser un grand aplat")
	for prop in OfficeBackdrop.props():
		assert_gte(prop["rect"].position.y, OfficeBackdrop.CEILING_Y, "%s doit etre sous le plafond" % prop["kind"])
