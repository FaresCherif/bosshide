extends Node2D

const SUCCESS_TEXT := "Well done, you made it to the toilets!\nTime: %s - Score: %d\nPress R to play again"

var _progress := LevelProgress.new()
var _door_key := DoorKey.new()
var _score := LevelScore.new()
var _door_code := DoorCode.new(DoorCode.random_code(RandomNumberGenerator.new()))
var _quiz := ColleagueQuiz.new(ColleagueQuiz.pick_question(QuizQuestions.QUESTIONS, RandomNumberGenerator.new()))

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
@onready var _chrono: Label = $Interface/Chrono
@onready var _post_it: Area2D = $PostIt
@onready var _post_it_code: Label = $PostIt/Code
@onready var _code_door: StaticBody2D = $PorteDigicode
@onready var _keypad: Panel = $Interface/Digicode
@onready var _keypad_entry: Label = $Interface/Digicode/Saisie
@onready var _keypad_error: Label = $Interface/Digicode/Erreur
@onready var _colleague: Area2D = $Collegue
@onready var _quiz_panel: Panel = $Interface/Collegue
@onready var _quiz_question: Label = $Interface/Collegue/Question
@onready var _quiz_choices: Label = $Interface/Collegue/Choix


func _ready() -> void:
	_goal.body_entered.connect(_on_arrivee_body_entered)
	_manager.body_spotted.connect(_on_manager_body_spotted)
	_patrolling_manager.body_spotted.connect(_on_manager_body_spotted)
	_post_it.body_exited.connect(_on_post_it_body_exited)
	_colleague.body_entered.connect(_on_collegue_body_entered)
	_post_it_code.text = _door_code.code()


func _physics_process(delta: float) -> void:
	_score.update(delta)
	_refresh_chrono()


func _refresh_chrono() -> void:
	_chrono.text = LevelScore.format_time(_score.elapsed())


func _unhandled_input(event: InputEvent) -> void:
	if _quiz.is_talking():
		_quiz_input(event)
	elif _door_code.is_keypad_open():
		_keypad_input(event)
	elif event.is_action_pressed("restart") and _progress.can_restart():
		get_tree().reload_current_scene()
	elif event.is_action_pressed("work") and _progress.can_move():
		_press_work()


# Le digicode, le post-it, la porte et la cle passent avant le travail
func _press_work() -> void:
	if not _door_code.is_door_open() and _code_door.is_body_near(_player):
		_set_keypad_open(true)
		return
	if _post_it.overlaps_body(_player):
		_door_code.read()
		_post_it_code.visible = _door_code.is_code_shown()
		return
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


# Pendant la saisie, le panneau prend toutes les touches
func _keypad_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("work"):
		_set_keypad_open(false)
	elif event.is_action_pressed("ui_accept"):
		_submit_code()
	elif event is InputEventKey and event.pressed and not event.echo:
		var digit := _digit_of(event)
		if digit >= 0:
			_door_code.type_digit(digit)
			_keypad_error.visible = false
		elif event.keycode == KEY_BACKSPACE:
			_door_code.erase()
	_refresh_keypad()
	get_viewport().set_input_as_handled()


# Chiffre d'une touche, ou -1 : rangee du haut par position (AZERTY compris) ou pave numerique
func _digit_of(event: InputEventKey) -> int:
	if event.physical_keycode >= KEY_0 and event.physical_keycode <= KEY_9:
		return event.physical_keycode - KEY_0
	if event.keycode >= KEY_KP_0 and event.keycode <= KEY_KP_9:
		return event.keycode - KEY_KP_0
	return -1


func _submit_code() -> void:
	match _door_code.submit():
		DoorCode.Result.WRONG:
			_score.add_penalty(LevelScore.WRONG_CODE_PENALTY)
			_patrolling_manager.attract(_code_door.position.x)
			_keypad_error.visible = true
		DoorCode.Result.RIGHT:
			_code_door.open()
			_player.set_busy(false)


func _set_keypad_open(open: bool) -> void:
	if open:
		_door_code.open_keypad()
	else:
		_door_code.close_keypad()
	_player.set_busy(_door_code.is_keypad_open())
	_keypad_error.visible = false
	_refresh_keypad()


func _refresh_keypad() -> void:
	_keypad.visible = _door_code.is_keypad_open()
	var slots := []
	for i in DoorCode.LENGTH:
		slots.append(_door_code.entry()[i] if i < _door_code.entry().length() else "_")
	_keypad_entry.text = " ".join(slots)


# Le collegue interpelle le joueur au passage : il le bloque jusqu'a sa reponse
func _on_collegue_body_entered(body: Node2D) -> void:
	if body != _player or not _progress.can_move() or not _quiz.start():
		return
	_player.set_busy(true)
	var question := _quiz.question()
	_quiz_question.text = question["text"]
	var lines := []
	for i in question["choices"].size():
		lines.append("%d. %s" % [i + 1, question["choices"][i]])
	_quiz_choices.text = "\n".join(lines)
	_quiz_panel.visible = true


# Pendant la question, seules les touches 1 a 3 comptent
func _quiz_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var result := _quiz.answer(_digit_of(event) - 1)
		if result == ColleagueQuiz.Result.WRONG:
			_score.add_penalty(LevelScore.WRONG_ANSWER_PENALTY)
			_patrolling_manager.attract(_colleague.position.x, ManagerPatrol.RUSH_FACTOR)
		if result != ColleagueQuiz.Result.IGNORED:
			_player.set_busy(false)
			_quiz_panel.visible = false
	get_viewport().set_input_as_handled()


func _on_post_it_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_door_code.stop_reading()
	_post_it_code.visible = _door_code.is_code_shown()


func _is_player_on_desk() -> bool:
	for desk: Area2D in _desks.get_children():
		if desk.overlaps_body(_player):
			return true
	return false


func _on_arrivee_body_entered(body: Node2D) -> void:
	if body != _player:
		return
	_progress.reach_goal()
	_freeze_level()
	_success_message.text = SUCCESS_TEXT % [LevelScore.format_time(_score.elapsed()), _score.score()]
	_success_message.visible = not _progress.is_game_over()


func _on_manager_body_spotted(body: Node2D) -> void:
	if body != _player or _player.is_working() or _quiz.is_talking():
		return
	_progress.fail()
	_game_over_message.visible = _progress.is_game_over()
	_freeze_level()


func _freeze_level() -> void:
	_score.stop()
	_refresh_chrono()
	_set_keypad_open(false)
	_player.set_physics_process(_progress.can_move())
	_manager.set_physics_process(_progress.can_move())
	_patrolling_manager.set_physics_process(_progress.can_move())
