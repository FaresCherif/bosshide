extends GutTest

const PLAYER_SCENE_PATH := "res://player/player.tscn"


func _instantiate_player() -> Node:
	var scene: PackedScene = load(PLAYER_SCENE_PATH)
	return autofree(scene.instantiate())


func test_player_est_un_character_body() -> void:
	assert_true(_instantiate_player() is CharacterBody2D, "Le joueur doit etre un CharacterBody2D")


func test_player_a_une_camera() -> void:
	var cameras := _instantiate_player().find_children("*", "Camera2D")
	assert_eq(cameras.size(), 1, "Le joueur doit porter une camera qui le suit")


func test_player_a_une_collision() -> void:
	var shapes := _instantiate_player().find_children("*", "CollisionShape2D")
	assert_eq(shapes.size(), 1, "Le joueur doit avoir une forme de collision")


func test_player_a_un_rectangle_visible() -> void:
	var rects := _instantiate_player().find_children("*", "ColorRect")
	assert_eq(rects.size(), 1, "Le joueur doit etre affiche par un rectangle")
