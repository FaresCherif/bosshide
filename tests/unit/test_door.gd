extends GutTest

const DOOR_SCENE_PATH := "res://level/door.tscn"


func _load_door() -> Node:
	var scene: PackedScene = load(DOOR_SCENE_PATH)
	return scene.instantiate()


func test_la_porte_s_instancie() -> void:
	var door: Node = autofree(_load_door())
	assert_true(door is StaticBody2D, "La porte doit bloquer le joueur")
	assert_true(door.get_node("Zone") is Area2D, "La porte doit detecter le joueur proche")


func test_la_porte_bloque_au_depart() -> void:
	var door: Node = add_child_autofree(_load_door())
	assert_true(door.visible, "La porte doit etre visible au depart")
	assert_false(door.get_node("CollisionShape2D").disabled, "La porte doit bloquer au depart")


func test_la_zone_depasse_la_porte() -> void:
	var door: Node = autofree(_load_door())
	var body_width: float = door.get_node("CollisionShape2D").shape.size.x
	var zone_width: float = door.get_node("Zone/CollisionShape2D").shape.size.x
	assert_gt(zone_width, body_width, "La zone doit toucher le joueur colle a la porte")


func test_ouvrir_cache_la_porte_et_la_rend_traversable() -> void:
	var door: Node = add_child_autofree(_load_door())
	door.open()
	await wait_physics_frames(2)
	assert_false(door.visible, "La porte ouverte doit disparaitre")
	assert_true(door.get_node("CollisionShape2D").disabled, "La porte ouverte ne doit plus bloquer")
