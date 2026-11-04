extends Node2D

var _progress := LevelProgress.new()

@onready var _player: CharacterBody2D = $Player
@onready var _goal: Area2D = $Arrivee
@onready var _manager: Node2D = $Manager
@onready var _success_message: Label = $Interface/MessageSucces
@onready var _game_over_message: Label = $Interface/MessageGameOver


func _ready() -> void:
	_goal.body_entered.connect(_on_arrivee_body_entered)
	_manager.body_spotted.connect(_on_manager_body_spotted)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart") and _progress.can_restart():
		get_tree().reload_current_scene()


func _on_arrivee_body_entered(body: Node2D) -> void:
	if body != _player:
		return
	_progress.reach_goal()
	_success_message.visible = not _progress.is_game_over()
	_freeze_level()


func _on_manager_body_spotted(body: Node2D) -> void:
	if body != _player:
		return
	_progress.fail()
	_game_over_message.visible = _progress.is_game_over()
	_freeze_level()


func _freeze_level() -> void:
	_player.set_physics_process(_progress.can_move())
	_manager.set_physics_process(_progress.can_move())
