extends GutTest


func test_les_ronds_vont_en_ligne_droite_de_la_tete_aux_bulles() -> void:
	var from := Vector2(560, 290)
	var to := Vector2(420, 230)
	var dots := ThoughtTrail.dots(from, to)
	assert_eq(dots.size(), ThoughtTrail.COUNT)
	var direction := (to - from).normalized()
	for dot in dots:
		var offset := Vector2(dot.x, dot.y) - from
		assert_almost_eq(offset.cross(direction), 0.0, 0.01, "Chaque rond doit etre sur la droite tete-bulles")
	assert_lt(Vector2(dots[0].x, dots[0].y).distance_to(from), Vector2(dots[-1].x, dots[-1].y).distance_to(from), "Les ronds montent vers les bulles")


func test_les_ronds_sont_reguliers_et_grossissent() -> void:
	var dots := ThoughtTrail.dots(Vector2(0, 100), Vector2(0, 0))
	var gap := dots[0].y - dots[1].y
	for i in range(1, dots.size()):
		assert_almost_eq(dots[i - 1].y - dots[i].y, gap, 0.01, "Les ronds doivent etre regulierement espaces")
		assert_gt(dots[i].z, dots[i - 1].z, "Les ronds doivent grossir en montant")
