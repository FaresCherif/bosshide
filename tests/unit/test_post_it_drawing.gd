extends GutTest


func test_les_lignes_sont_regulieres_sous_la_marge() -> void:
	var style := RuledStickyStyle.new()
	style.top_margin = 40.0
	style.bottom_margin = 20.0
	style.spacing = 30.0
	assert_eq(style.line_positions(Rect2(0, 0, 300, 200)), PackedFloat32Array([40.0, 70.0, 100.0, 130.0, 160.0]), "Une ligne tous les 30 px entre les marges")


func test_les_lignes_suivent_le_haut_du_rectangle() -> void:
	var style := RuledStickyStyle.new()
	style.top_margin = 40.0
	style.bottom_margin = 20.0
	style.spacing = 30.0
	assert_eq(style.line_positions(Rect2(10, 100, 300, 100)), PackedFloat32Array([140.0, 170.0]), "Les lignes partent du haut du post-it")


func test_sans_place_il_n_y_a_pas_de_ligne() -> void:
	var style := RuledStickyStyle.new()
	assert_eq(style.line_positions(Rect2(0, 0, 300, 10)).size(), 0, "Une feuille trop petite n'a pas de ligne")


func test_la_punaise_tient_dans_sa_boite() -> void:
	var pin: PushPin = autofree(PushPin.new())
	pin.size = Vector2(40, 40)
	assert_lte(pin.head_radius() * 2.0, pin.size.x, "La tete de la punaise doit tenir dans sa boite")
	assert_gt(pin.head_radius(), 0.0)


func test_le_liege_est_dans_le_cadre() -> void:
	var board: CorkBoard = autofree(CorkBoard.new())
	board.size = Vector2(800, 600)
	board.frame_width = 20.0
	assert_eq(board.cork_rect(), Rect2(20, 20, 760, 560), "Le liege doit etre entoure du cadre")


func test_les_grains_du_liege_sont_fixes_et_dans_le_liege() -> void:
	var board: CorkBoard = autofree(CorkBoard.new())
	board.size = Vector2(800, 600)
	var grains := board.speckles()
	assert_eq(grains.size(), board.speckle_count, "Le liege doit avoir tous ses grains")
	assert_eq(grains, board.speckles(), "Les grains ne doivent pas bouger d'une image a l'autre")
	for grain in grains:
		assert_true(board.cork_rect().has_point(grain), "Chaque grain doit etre dans le liege")
