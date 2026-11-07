extends GutTest

const DESK_SCENE_PATH := "res://level/desk.tscn"


func _add_desk() -> Node:
	var scene: PackedScene = load(DESK_SCENE_PATH)
	return add_child_autofree(scene.instantiate())


func test_le_bureau_est_une_zone() -> void:
	assert_true(_add_desk() is Area2D, "Le bureau doit etre une zone que le joueur traverse")


func test_le_visuel_couvre_la_forme() -> void:
	var desk := _add_desk()
	var shape: RectangleShape2D = desk.get_node("CollisionShape2D").shape
	var visual: ColorRect = desk.get_node("Visuel")
	assert_eq(visual.size, shape.size, "Le visuel doit avoir la taille de la zone")


func test_le_bureau_est_bleu() -> void:
	var color: Color = _add_desk().get_node("Visuel").color
	assert_gt(color.b, color.r, "Le bleu doit dominer le rouge")
	assert_gt(color.b, color.g, "Le bleu doit dominer le vert")
