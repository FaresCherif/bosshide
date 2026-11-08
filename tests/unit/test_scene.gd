extends GutTest

const MAIN_SCENE_PATH := "res://Game.tscn"


func test_main_scene_loads() -> void:
	assert_true(ResourceLoader.exists(MAIN_SCENE_PATH), "La scene principale doit exister")


func test_main_scene_instantiates() -> void:
	var scene: PackedScene = load(MAIN_SCENE_PATH)
	var instance: Node = autofree(scene.instantiate())
	assert_not_null(instance, "La scene principale doit pouvoir etre instanciee")
