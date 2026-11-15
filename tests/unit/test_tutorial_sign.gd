extends GutTest

const SCENE_PATH := "res://level/tutorial_sign.tscn"


func _add_sign(text: String) -> Node2D:
	var scene: PackedScene = load(SCENE_PATH)
	var sign: Node2D = scene.instantiate()
	sign.text = text
	return add_child_autofree(sign)


func test_la_scene_s_instancie() -> void:
	var sign := _add_sign("Look busy.")
	assert_true(sign is TutorialSign, "L'affiche doit utiliser son script")


func test_le_texte_est_ecrit_sur_l_affiche() -> void:
	var sign := _add_sign("Desk = invisible.")
	assert_eq(sign.get_node("Feuille/Texte").text, "Desk = invisible.", "Le texte reglable doit s'afficher")


func test_le_texte_est_au_marqueur() -> void:
	var label: Label = _add_sign("Hurry.").get_node("Feuille/Texte")
	var font := label.get_theme_font("font")
	assert_string_contains(font.resource_path, "PermanentMarker", "L'affiche est ecrite au marqueur")


func test_l_affiche_est_au_mur_au_dessus_des_tetes() -> void:
	var sheet: Control = _add_sign("Hurry.").get_node("Feuille")
	assert_lt(sheet.position.y + sheet.size.y, -100.0, "L'affiche ne doit pas cacher le joueur")
	assert_eq(sheet.mouse_filter, Control.MOUSE_FILTER_IGNORE, "L'affiche ne doit pas capter la souris")


func test_l_affiche_ne_bloque_rien() -> void:
	var sign := _add_sign("Hurry.")
	assert_eq(sign.find_children("*", "CollisionObject2D", true, false).size(), 0, "L'affiche est purement decorative")
