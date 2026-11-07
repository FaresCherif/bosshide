extends Node2D

signal body_spotted(body: Node2D)

const VISION_LENGTH := 150.0

@export var left_limit := -300.0
@export var right_limit := 300.0

var _patrol: ManagerPatrol

@onready var _zone: Area2D = $Zone
@onready var _zone_shape: CollisionShape2D = $Zone/CollisionShape2D
@onready var _zone_visual: ColorRect = $ZoneVisuelle


func _ready() -> void:
	_patrol = ManagerPatrol.new(left_limit, right_limit)
	_refresh_display()


func _physics_process(delta: float) -> void:
	_patrol.update(delta)
	_refresh_display()
	for body in _zone.get_overlapping_bodies():
		body_spotted.emit(body)


# Place le manager et met sa zone de vision devant lui
func _refresh_display() -> void:
	position.x = _patrol.get_x()
	var zone_center := _patrol.get_direction() * VISION_LENGTH / 2.0
	_zone_shape.position.x = zone_center
	_zone_visual.position.x = zone_center - VISION_LENGTH / 2.0
