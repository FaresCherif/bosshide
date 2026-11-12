class_name Game
extends Node

# Menu principal, selecteur de niveau, puis niveaux charges un par un avec leurs scores

enum Screen { MENU, PHOTO, SELECTOR, LEVEL, PAUSE, END }

const LEVELS := ["res://levels/level_01.tscn", "res://levels/level_02.tscn"]
const LEVEL_NODE_NAME := "Niveau"
# Angle de chaque post-it du selecteur : toujours le meme pour un niveau donne
const TILTS := [-0.05, 0.035, -0.02, 0.045, -0.03]
const END_TEXT := "Annual review: %d points.\nYour reward: more work.\nR: play again - Esc: level select"

# Badge du menu : le niveau demarre apres le bip de la pointeuse
const CLOCK_IN_DELAY := 0.5
const BADGE_PIVOT := Vector2(220, -64)
const BADGE_SWING := 0.035
const LED_RED := Color(0.85, 0.15, 0.2, 1)
const LED_GREEN := Color(0.25, 0.85, 0.4, 1)

# Reglable pour que les tests n'attendent pas le bip
var clock_in_delay := CLOCK_IN_DELAY
var _clocking_in := false
var _sequence := LevelSequence.new(LEVELS)
var _profile := EmployeeProfile.new()
var _level: Node = null
var _screen := Screen.MENU

@onready var _background: ColorRect = $Interface/Fond
@onready var _level_label: Label = $Interface/Niveau
@onready var _end_screen: Label = $Interface/FinDuJeu
@onready var _menu: Control = $Interface/MenuPrincipal
@onready var _play_button: Button = $Interface/MenuPrincipal/Boutons/Jouer
@onready var _select_button: Button = $Interface/MenuPrincipal/Boutons/Choisir
@onready var _quit_button: Button = $Interface/MenuPrincipal/Boutons/Quitter
@onready var _badge: Control = $Interface/MenuPrincipal/Badge
@onready var _badge_led: ColorRect = $Interface/MenuPrincipal/Badge/Voyant
@onready var _access_granted: Label = $Interface/MenuPrincipal/Badge/Acces
@onready var _badge_photo: IdPhoto = $Interface/MenuPrincipal/Badge/Photo
@onready var _photo_button: Button = $Interface/MenuPrincipal/Badge/BoutonPhoto
@onready var _picker: Control = $Interface/MenuPrincipal/ChoixPhoto
@onready var _picker_icons: GridContainer = $Interface/MenuPrincipal/ChoixPhoto/Icones
@onready var _keep_button: Button = $Interface/MenuPrincipal/ChoixPhoto/Garder
@onready var _selector: Control = $Interface/Selecteur
@onready var _level_buttons: GridContainer = $Interface/Selecteur/Niveaux
@onready var _back_button: Button = $Interface/Selecteur/Retour
@onready var _pause: Control = $Interface/Pause
@onready var _pause_title: Label = $Interface/Pause/Titre
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
	_photo_button.pressed.connect(_open_photo_picker)
	_keep_button.pressed.connect(_close_photo_picker)
	for icon in EmployeeProfile.ICONS:
		_picker_icons.add_child(_new_icon_choice(icon["id"], icon["name"]))
	for i in LEVELS.size():
		_level_buttons.add_child(_new_level_post_it(i + 1))
	# La grille remet la rotation a zero a chaque tri : on repenche les post-its ensuite
	_level_buttons.sort_children.connect(_tilt_level_post_its)
	_show_menu()
	UiFx.swing(_badge, BADGE_PIVOT, BADGE_SWING)


func _unhandled_input(event: InputEvent) -> void:
	match _screen:
		Screen.PHOTO:
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				_close_photo_picker()
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


# Choix d'icone : post-it avec la photo dessinee et son nom
func _new_icon_choice(id: String, icon_name: String) -> Button:
	var button := Button.new()
	button.name = id
	button.custom_minimum_size = Vector2(140, 150)
	button.pressed.connect(_choose_icon.bind(id))
	var photo := IdPhoto.new()
	photo.icon_id = id
	photo.position = Vector2(30, 10)
	photo.size = Vector2(80, 100)
	photo.clip_contents = true
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(photo)
	var label := Label.new()
	label.text = icon_name
	label.position = Vector2(0, 112)
	label.size = Vector2(140, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	return button


# Le menu reste visible sous le choix, mais ses boutons sont inactifs
func _open_photo_picker() -> void:
	_set_screen(Screen.PHOTO)
	_set_menu_enabled(false)
	_picker_icons.get_node(_profile.icon_id()).call_deferred("grab_focus")


func _close_photo_picker() -> void:
	_set_screen(Screen.MENU)
	_set_menu_enabled(true)
	_photo_button.call_deferred("grab_focus")


func _choose_icon(id: String) -> void:
	if _profile.select(id):
		_badge_photo.icon_id = id
	_close_photo_picker()


func _set_menu_enabled(enabled: bool) -> void:
	for button in [_play_button, _select_button, _quit_button, _photo_button]:
		button.disabled = not enabled


# Post-it de niveau : bouton ligne, punaise au coin, tampon LOCKED si verrouille
func _new_level_post_it(number: int) -> Button:
	var button := Button.new()
	button.theme_type_variation = &"StickyButton"
	button.custom_minimum_size = Vector2(180, 130)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(_on_level_button_pressed.bind(number))
	var pin := PushPin.new()
	pin.name = "Punaise"
	pin.position = Vector2(-10, -12)
	pin.size = Vector2(34, 34)
	pin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(pin)
	var stamp := Label.new()
	stamp.name = "Tampon"
	stamp.text = "LOCKED"
	stamp.theme_type_variation = &"StampLabel"
	# Dans la marge du haut, pour laisser lisible le texte du niveau
	stamp.add_theme_font_size_override("font_size", 20)
	stamp.position = Vector2(56, -4)
	stamp.rotation = -0.12
	stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamp.visible = false
	button.add_child(stamp)
	return button


func _tilt_level_post_its() -> void:
	for i in _level_buttons.get_child_count():
		var button: Control = _level_buttons.get_child(i)
		button.pivot_offset = button.size / 2.0
		button.rotation = TILTS[i % TILTS.size()]


# Un seul ecran visible a la fois
func _set_screen(screen: Screen) -> void:
	_screen = screen
	_background.visible = screen in [Screen.MENU, Screen.PHOTO, Screen.SELECTOR, Screen.END]
	_menu.visible = screen == Screen.MENU or screen == Screen.PHOTO
	_picker.visible = screen == Screen.PHOTO
	_selector.visible = screen == Screen.SELECTOR
	_level_label.visible = screen == Screen.LEVEL or screen == Screen.PAUSE
	_pause.visible = screen == Screen.PAUSE
	_end_screen.visible = screen == Screen.END


func _show_menu() -> void:
	_unload_level()
	_set_screen(Screen.MENU)
	_reset_badge()
	_play_button.call_deferred("grab_focus")


# Badge pret a etre passe : voyant rouge, boutons actifs
func _reset_badge() -> void:
	_clocking_in = false
	_badge_led.color = LED_RED
	_access_granted.visible = false
	_set_menu_enabled(true)


func _show_selector() -> void:
	_unload_level()
	_set_screen(Screen.SELECTOR)
	for i in _level_buttons.get_child_count():
		var button: Button = _level_buttons.get_child(i)
		var unlocked := _sequence.is_unlocked(i + 1)
		button.disabled = not unlocked
		button.text = _level_button_text(i + 1, unlocked)
		button.get_node("Tampon").visible = not unlocked
	_level_buttons.get_child(0).call_deferred("grab_focus")


func _level_button_text(number: int, unlocked: bool) -> String:
	if not unlocked:
		return "Level %d\n(locked by HR)" % number
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
	_level.set_employee_icon(_profile.icon_id())
	_level_label.text = "Level %d/%d" % [_sequence.level_number(), _sequence.level_count()]


# Le niveau est retire tout de suite pour que le suivant puisse prendre son nom
func _unload_level() -> void:
	if _level == null:
		return
	remove_child(_level)
	_level.queue_free()
	_level = null


# Le badge est accepte (voyant vert, ACCESS GRANTED), puis le niveau 1 demarre
func _on_jouer_pressed() -> void:
	if _clocking_in:
		return
	_clocking_in = true
	_set_menu_enabled(false)
	_badge_led.color = LED_GREEN
	_access_granted.visible = true
	UiFx.stamp(_access_granted, _access_granted.rotation)
	if clock_in_delay <= 0.0:
		_start_first_level()
		return
	var tween := create_tween()
	tween.tween_interval(clock_in_delay)
	tween.tween_callback(_start_first_level)


func _start_first_level() -> void:
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
	UiFx.pop_in(_pause_title)
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
