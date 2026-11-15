extends GutTest

# Rouleau de papier toilette de l'ecran de reussite : calculs de dessin et d'apparition


func test_les_pointilles_separent_des_feuilles_regulieres() -> void:
	var lines := ToiletPaper.perforations(540.0, 108.0)
	assert_eq(Array(lines), [108.0, 216.0, 324.0, 432.0], "Une ligne de pointilles entre deux feuilles, pas au bout")


func test_pas_de_pointilles_sur_une_bande_plus_courte_qu_une_feuille() -> void:
	assert_eq(ToiletPaper.perforations(80.0, 108.0).size(), 0)


func test_une_ligne_apparait_quand_le_papier_l_atteint() -> void:
	assert_eq(ToiletPaper.reveal_delay(0.0, 540.0, 0.8), 0.0, "Le haut de la bande apparait tout de suite")
	assert_almost_eq(ToiletPaper.reveal_delay(270.0, 540.0, 0.8), 0.4, 0.001, "Le milieu apparait a mi-deroulement")
	assert_eq(ToiletPaper.reveal_delay(900.0, 540.0, 0.8), 0.8, "Le delai ne depasse pas la duree")
	assert_eq(ToiletPaper.reveal_delay(-50.0, 540.0, 0.8), 0.0, "Au-dessus de la bande, pas de delai negatif")


func test_le_bord_dechire_va_d_un_cote_a_l_autre_en_dents_de_scie() -> void:
	var points := ToiletPaper.tear_points(440.0, 500.0, 10.0)
	assert_eq(points[0].x, 0.0, "Le bord commence a gauche")
	assert_eq(points[-1].x, 440.0, "Le bord finit a droite")
	for i in range(1, points.size()):
		assert_gt(points[i].x, points[i - 1].x, "Le bord avance vers la droite")
		assert_ne(points[i].y, points[i - 1].y, "Le bord alterne haut et bas")
		assert_between(points[i].y, 490.0, 500.0, "Les dents restent au bout de la bande")


func test_le_rouleau_s_instancie_deroule() -> void:
	var paper: ToiletPaper = autofree(ToiletPaper.new())
	assert_eq(paper.unrolled, 1.0, "Dans l'editeur, le papier est deja deroule")
	paper.unrolled = 0.0
	assert_eq(paper.strip_length(), 0.0, "Enroule, la bande n'a pas de longueur")
