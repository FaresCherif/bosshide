class_name Game
extends Node

# Menu principal, selecteur de niveau, puis niveaux charges un par un avec leurs scores

enum Screen { MENU, SELECTOR, LEVEL, PAUSE, END }

const LEVELS := ["res://levels/level_01.tscn", "res://levels/level_02.tscn"]
const LEVEL_NODE_NAME := "Niveau"
const END_TEXT := "All levels done! Total score: %d\nR: play again - Esc: level select"

var _sequence := LevelSequence.new(LEVELS)
var _level: Node = null
var _screen := Screen.MENU

@onready var _level_label: Label = $Interface/Niveau
@onready var _end_screen: Label = $Interface/FinDuJeu
@onready var _menu: Control = $Interface/MenuPrincipal
@onready var _play_button: Button = $Interface/MenuPrincipal/Boutons/Jouer
@onready var _select_button: Button = $Interface/MenuPrincipal/Boutons/Choisir
@onready var _quit_button: Button = $Interface/MenuPrincipal/Boutons/Quitter
@onready var _selector: Control = $Interface/Selecteur
@onready var _level_buttons: GridContainer = $Interface/Selecteur/Niveaux
@onready var _back_button: Button = $Interface/Selecteur/Retour
@onready var _pause: Control = $Interface/Pause
@onready var _resume_button: Button = $Interface/Pause/Boutons/Reprendre
@onready var _pause_select_button: Button = $Interface/Pause/Boutons/Selection
@onready var _pause_menu_button: Button = $Interface/Pause/Boutons/Menu


func _ready() -> void:
	_play_button.pressed.connect(_on_jouer_pressed)
	_select_button.pressed.connect(_on_choisir_pressed)
	_quit_button.pressed.connect(_on_quitter_pressed)
	_back_button.pressed.connect(_on_retour_pressed)
	_resume_button.pressed.connect(_on_reprendre_pressed)
	_pause_select_button.pressed.connect(_on_selection_pressed)
	_pause_menu_button.pressed.connect(_on_menu_pressed)
	for i in LEVELS.size():
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 80)
		button.add_theme_font_size_override("font_size", 22)
		button.pressed.connect(_on_level_button_pressed.bind(i + 1))
		_level_buttons.add_child(button)
	_show_menu()


func _unhandled_input(event: InputEvent) -> void:
	match _screen:
		Screen.SELECTOR:
			if event.is_action_pressed("ui_cancel"):
				_show_menu()
		Screen.PAUSE:
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				_resume()
		Screen.END:
			if event.is_action_pressed("restart"):
				_sequence.restart_all()
				_load_current_level()
			elif event.is_action_pressed("ui_cancel"):
				_show_selector()


# Un seul ecran visible a la fois
func _set_screen(screen: Screen) -> void:
	_screen = screen
	_menu.visible = screen == Screen.MENU
	_selector.visible = screen == Screen.SELECTOR
	_level_label.visible = screen == Screen.LEVEL or screen == Screen.PAUSE
	_pause.visible = screen == Screen.PAUSE
	_end_screen.visible = screen == Screen.END


func _show_menu() -> void:
	_unload_level()
	_set_screen(Screen.MENU)
	_play_button.call_deferred("grab_focus")


func _show_selector() -> void:
	_unload_level()
	_set_screen(Screen.SELECTOR)
	for i in _level_buttons.get_child_count():
		var button: Button = _level_buttons.get_child(i)
		var unlocked := _sequence.is_unlocked(i + 1)
		button.disabled = not unlocked
		button.text = _level_button_text(i + 1, unlocked)
	_level_buttons.get_child(0).call_deferred("grab_focus")


func _level_button_text(number: int, unlocked: bool) -> String:
	if not unlocked:
		return "Level %d (locked)" % number
	if _sequence.has_best_score(number):
		return "Level %d\nBest: %d" % [number, _sequence.best_score(number)]
	return "Level %d" % number


func _load_current_level() -> void:
	_unload_level()
	if _sequence.is_finished():
		_set_screen(Screen.END)
		_end_screen.text = END_TEXT % _sequence.total_score()
		return
	_set_screen(Screen.LEVEL)
	var scene: PackedScene = load(_sequence.current_path())
	_level = scene.instantiate()
	_level.name = LEVEL_NODE_NAME
	_level.succeeded.connect(_on_level_succeeded)
	_level.restart_requested.connect(_on_level_restart_requested)
	_level.next_requested.connect(_on_level_next_requested)
	_level.menu_requested.connect(_on_level_menu_requested)
	_level.pause_requested.connect(_on_level_pause_requested)
	add_child(_level)
	_level.configure(_sequence.level_number(), _sequence.is_last())
	_level_label.text = "Level %d/%d" % [_sequence.level_number(), _sequence.level_count()]


# Le niveau est retire tout de suite pour que le suivant puisse prendre son nom
func _unload_level() -> void:
	if _level == null:
		return
	remove_child(_level)
	_level.queue_free()
	_level = null


func _on_jouer_pressed() -> void:
	_sequence.select(1)
	_load_current_level()


func _on_choisir_pressed() -> void:
	_show_selector()


func _on_quitter_pressed() -> void:
	get_tree().quit()


func _on_retour_pressed() -> void:
	_show_menu()


func _on_level_button_pressed(number: int) -> void:
	if _sequence.select(number):
		_load_current_level()


func _on_level_succeeded(score: int) -> void:
	var is_new := _sequence.record_score(score)
	_level.show_best(_sequence.best_score(_sequence.level_number()), is_new)


func _on_level_restart_requested() -> void:
	_load_current_level()


func _on_level_next_requested() -> void:
	_sequence.advance()
	_load_current_level()


func _on_level_menu_requested() -> void:
	_show_selector()


# Le niveau reste charge mais fige : joueur, managers et chrono s'arretent
func _on_level_pause_requested() -> void:
	_level.process_mode = Node.PROCESS_MODE_DISABLED
	_set_screen(Screen.PAUSE)
	_resume_button.call_deferred("grab_focus")


func _resume() -> void:
	_level.process_mode = Node.PROCESS_MODE_INHERIT
	_set_screen(Screen.LEVEL)


func _on_reprendre_pressed() -> void:
	_resume()


func _on_selection_pressed() -> void:
	_show_selector()


func _on_menu_pressed() -> void:
	_show_menu()
