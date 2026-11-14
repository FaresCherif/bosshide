extends GutTest

const SCREEN := Vector2(1152, 648)
const SIZE := Vector2(300, 120)


func test_la_bulle_est_au_dessus_de_l_ancre_du_cote_demande() -> void:
	var right := SpeechBubble.place(Vector2(500, 300), SIZE, SCREEN, SpeechBubble.Side.RIGHT)
	assert_lt(right.end.y, 300.0, "La bulle doit etre au-dessus de la tete")
	assert_lt(right.position.x, 500.0, "La pointe doit etre dans la bulle")
	assert_gt(right.get_center().x, 500.0, "La bulle doit partir vers la droite")
	var left := SpeechBubble.place(Vector2(500, 300), SIZE, SCREEN, SpeechBubble.Side.LEFT)
	assert_lt(left.get_center().x, 500.0, "La bulle doit partir vers la gauche")
	assert_gt(left.end.x, 500.0, "La pointe doit etre dans la bulle")


func test_la_bulle_reste_dans_l_ecran() -> void:
	var screen := Rect2(Vector2.ZERO, SCREEN)
	for anchor in [Vector2(10, 300), Vector2(1140, 300), Vector2(500, 40)]:
		for side in [SpeechBubble.Side.LEFT, SpeechBubble.Side.RIGHT]:
			var rect := SpeechBubble.place(anchor, SIZE, SCREEN, side)
			assert_true(screen.encloses(rect), "La bulle %s doit tenir dans l'ecran" % rect)


func test_la_pointe_reste_dans_la_bulle() -> void:
	var rect := Rect2(100, 100, 300, 120)
	assert_eq(SpeechBubble.tail_offset(Vector2(150, 260), rect), 50.0)
	assert_eq(SpeechBubble.tail_offset(Vector2(0, 260), rect), SpeechBubble.TAIL_MARGIN, "La pointe ne doit pas sortir a gauche")
	assert_eq(SpeechBubble.tail_offset(Vector2(900, 260), rect), 300.0 - SpeechBubble.TAIL_MARGIN, "La pointe ne doit pas sortir a droite")


func test_les_deux_bulles_se_dessinent() -> void:
	var viewport: SubViewport = add_child_autofree(SubViewport.new())
	viewport.size = Vector2i(400, 300)
	for thought in [false, true]:
		var bubble := SpeechBubble.new()
		bubble.thought = thought
		bubble.size = SIZE
		bubble.tail_x = 80.0
		viewport.add_child(bubble)
	await wait_frames(1)
	assert_eq(viewport.get_child_count(), 2)


func test_une_bulle_se_decale_pour_ne_pas_en_cacher_une_autre() -> void:
	var speech := Rect2(456, 150, 360, 120)
	var thought := SpeechBubble.avoid(Rect2(200, 120, 340, 150), speech, SCREEN)
	assert_false(thought.intersects(speech), "Les bulles ne doivent pas se chevaucher")
	assert_eq(thought.end.x, speech.position.x - SpeechBubble.GAP, "La bulle se range juste a gauche")
	assert_eq(thought.position.y, 120.0, "Elle garde sa hauteur")


func test_sans_place_a_gauche_la_bulle_passe_au_dessus() -> void:
	var speech := Rect2(100, 300, 360, 120)
	var thought := SpeechBubble.avoid(Rect2(20, 280, 340, 150), speech, SCREEN)
	assert_false(thought.intersects(speech), "Les bulles ne doivent pas se chevaucher")
	assert_true(Rect2(Vector2.ZERO, SCREEN).encloses(thought), "La bulle doit rester dans l'ecran")


func test_une_bulle_a_l_ecart_ne_bouge_pas() -> void:
	var thought := Rect2(20, 100, 200, 100)
	assert_eq(SpeechBubble.avoid(thought, Rect2(600, 100, 200, 100), SCREEN), thought)

