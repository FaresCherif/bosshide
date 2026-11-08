class_name Game
extends Node

# Charge les niveaux un par un et cumule leurs scores

const LEVELS := ["res://levels/level_01.tscn", "res://levels/level_02.tscn"]
const LEVEL_NODE_NAME := "Niveau"
const END_TEXT := "All levels done! Total score: %d\nPress R to play again"

var _sequence := LevelSequence.new(LEVELS)
var _level: Node = null

@onready var _level_label: Label = $Interface/Niveau
@onready var _end_screen: Label = $Interface/FinDuJeu


func _ready() -> void:
	_load_current_level()


func _unhandled_input(event: InputEvent) -> void:
	if _sequence.is_finished() and event.is_action_pressed("restart"):
		_sequence.restart_all()
		_load_current_level()


func _load_current_level() -> void:
	_unload_level()
	_end_screen.visible = _sequence.is_finished()
	_level_label.visible = not _sequence.is_finished()
	if _sequence.is_finished():
		_end_screen.text = END_TEXT % _sequence.total_score()
		return
	var scene: PackedScene = load(_sequence.current_path())
	_level = scene.instantiate()
	_level.name = LEVEL_NODE_NAME
	_level.succeeded.connect(_on_level_succeeded)
	_level.restart_requested.connect(_on_level_restart_requested)
	_level.next_requested.connect(_on_level_next_requested)
	add_child(_level)
	_level_label.text = "Level %d/%d" % [_sequence.level_number(), _sequence.level_count()]


# Le niveau est retire tout de suite pour que le suivant puisse prendre son nom
func _unload_level() -> void:
	if _level == null:
		return
	remove_child(_level)
	_level.queue_free()
	_level = null


func _on_level_succeeded(score: int) -> void:
	_sequence.record_score(score)


func _on_level_restart_requested() -> void:
	_load_current_level()


func _on_level_next_requested() -> void:
	_sequence.advance()
	_load_current_level()
