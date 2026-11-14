extends GutTest


func test_la_camera_s_arrete_aux_bords_exterieurs_des_murs() -> void:
	var left_wall := Rect2(-1520, -400, 40, 800)
	var right_wall := Rect2(1480, -400, 40, 800)
	assert_eq(LevelBounds.camera_limits(left_wall, right_wall), Vector2i(-1520, 1520), "La camera ne doit pas montrer l'exterieur du batiment")


func test_le_rectangle_d_un_mur() -> void:
	assert_eq(LevelBounds.wall_rect(Vector2(-1500, 0), Vector2(40, 800)), Rect2(-1520, -400, 40, 800))


func test_la_camera_s_arrete_juste_sous_le_sol() -> void:
	var floor_rect := Rect2(-1500, 32, 3000, 40)
	assert_eq(LevelBounds.camera_bottom(floor_rect), 72 + LevelBounds.CARPET_MARGIN, "On ne voit qu'une bande de moquette sous le sol")
