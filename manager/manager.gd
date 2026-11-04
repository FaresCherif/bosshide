extends Node2D

signal body_spotted(body: Node2D)

const FACING_COLOR := Color(0.9, 0.55, 0.2, 1)
const BACK_COLOR := Color(0.4, 0.3, 0.25, 1)

var _watch := ManagerWatch.new()

@onready var _body_visual: ColorRect = $Visuel
@onready var _zone_visual: ColorRect = $ZoneVisuelle
@onready var _zone: Area2D = $Zone


func _ready() -> void:
	_refresh_display()


func _physics_process(delta: float) -> void:
	_watch.update(delta)
	_refresh_display()
	if not _watch.is_facing():
		return
	# Test a chaque frame : couvre aussi le joueur deja dans la zone au retournement
	for body in _zone.get_overlapping_bodies():
		body_spotted.emit(body)


func _refresh_display() -> void:
	var facing := _watch.is_facing()
	_body_visual.color = FACING_COLOR if facing else BACK_COLOR
	_zone_visual.visible = facing
