extends GutTest

const IMAGE := Vector2i(1152, 648)
const CROP := Vector2i(480, 300)


func test_le_recadrage_est_centre_sur_le_joueur() -> void:
	assert_eq(SurveillanceShot.crop_rect(Vector2(576, 324), IMAGE, CROP), Rect2i(336, 174, 480, 300))


func test_le_recadrage_reste_dans_l_image() -> void:
	assert_eq(SurveillanceShot.crop_rect(Vector2(20, 640), IMAGE, CROP), Rect2i(0, 348, 480, 300), "Pres du bord, le cadre est recale")
	assert_eq(SurveillanceShot.crop_rect(Vector2(1150, 10), IMAGE, CROP), Rect2i(672, 0, 480, 300))


func test_une_image_trop_petite_est_prise_en_entier() -> void:
	assert_eq(SurveillanceShot.crop_rect(Vector2(50, 40), Vector2i(200, 100), CROP), Rect2i(0, 0, 200, 100))


func test_le_cadre_rouge_suit_le_joueur_dans_la_photo() -> void:
	var crop := Rect2i(336, 174, 480, 300)
	assert_eq(SurveillanceShot.frame_position(Vector2(576, 324), crop, Vector2(240, 150)), Vector2(120, 75), "Le joueur au centre de la capture est au centre de la photo")
	assert_eq(SurveillanceShot.frame_position(Vector2(336, 174), crop, Vector2(240, 150)), Vector2(0, 0))


func test_la_legende_de_la_camera() -> void:
	assert_eq(SurveillanceShot.caption("00:42.3"), "CAM 03 - REC 00:42.3")
