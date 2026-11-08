extends Node2D

var _progress := LevelProgress.new()
var _door_key := DoorKey.new()

@onready var _player: CharacterBody2D = $Player
@onready var _goal: Area2D = $Arrivee
@onready var _manager: Node2D = $Manager
@onready var _patrolling_manager: Node2D = $ManagerPatrouille
@onready var _desks: Node2D = $Bureaux
@onready var _key: Area2D = $Cle
@onready var _door: StaticBody2D = $Porte
@onready var _key_indicator: Label = $Interface/IndicateurCle
@onready var _success_message: Label = $Interface/MessageSucces
@onready var _game_over_message: Label = $Interface/MessageGameOver


func _ready() -> void:
	_goal.body_entered.connect(_on_arrivee_body_entered)
	_manager.body_spotted.connect(_on_manager_body_spotted)
	_patrolling_manager.body_spotted.connect(_on_manager_body_spotted)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and _progress.can_restart():
		get_tree().reload_current_scene()
	elif event.is_action_pressed("work") and _progress.can_move():
		_press_work()


# La porte et la cle passent avant le travail ; l'appui sert a travailler sinon
func _press_work() -> void:
	var on_key := _door_key.is_key_on_desk() and _key.overlaps_body(_player)
	if _door_key.interact(_door.is_body_near(_player), on_key):
		_refresh_door_key()
	else:
		_player.press_work(_is_player_on_desk())


func _refresh_door_key() -> void:
	_key.visible = _door_key.is_key_on_desk()
	_key_indicator.visible = _door_key.has_key()
	if _door_key.is_door_open():
		_door.open()


func _is_player_on_desk() -> bool:
	for desk: Area2D in _desks.get_children():
		if desk.overlaps_body(_player):
			return true
	return false


func _on_arrivee_body_entered(body: Node2D) -> void:
	if body != _player:
		return
	_progress.reach_goal()
	_success_message.visible = not _progress.is_game_over()
	_freeze_level()


func _on_manager_body_spotted(body: Node2D) -> void:
	if body != _player or _player.is_working():
		return
	_progress.fail()
	_game_over_message.visible = _progress.is_game_over()
	_freeze_level()


func _freeze_level() -> void:
	_player.set_physics_process(_progress.can_move())
	_manager.set_physics_process(_progress.can_move())
	_patrolling_manager.set_physics_process(_progress.can_move())
