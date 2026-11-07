extends Node2D

signal body_spotted(body: Node2D)

const FACING_COLOR := Color(0.9, 0.55, 0.2, 1)
const BACK_COLOR := Color(0.4, 0.3, 0.25, 1)

var _watch := ManagerWatch.new()

@onready var _body_visual: ColorRect = $Visuel
@onready var _zone_visual: ColorRect = $ZoneVisuelle
@onready var _sector_visual: ColorRect = $SecteurVisuel
@onready var _zone: Area2D = $Zone
@onready var _zone_width: float = $Zone/CollisionShape2D.shape.size.x


func _ready() -> void:
	_refresh_display()


func _physics_process(delta: float) -> void:
	_watch.update(delta)
	_refresh_display()
	# Test a chaque frame : couvre aussi le joueur deja la quand le regard arrive
	for body in _zone.get_overlapping_bodies():
		if _watch.sees(body.global_position.x - global_position.x, _zone_width):
			body_spotted.emit(body)


func _refresh_display() -> void:
	var facing := _watch.is_facing()
	_body_visual.color = FACING_COLOR if facing else BACK_COLOR
	_zone_visual.visible = facing
	_sector_visual.visible = facing
	var sector_width := _sector_visual.size.x
	_sector_visual.position.x = _watch.current_sector() * sector_width - sector_width / 2.0
