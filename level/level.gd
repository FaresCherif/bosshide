extends Node2D

# Script commun a tous les niveaux. Bureaux et managers sont trouves par groupe ;
# cle/porte, post-it/digicode et collegue sont optionnels (0 ou 1 par niveau).

signal succeeded(score: int)
signal restart_requested
signal next_requested
signal menu_requested
signal pause_requested

const STAMP_ANGLE := -0.14
const SURVEILLANCE_CROP := Vector2i(480, 300)
const PLAYER_HALF_HEIGHT := 32.0
const BACKDROP_SCENE := preload("res://level/office_backdrop.tscn")
const HOME_DESK_SCENE := preload("res://level/home_desk.tscn")
const QUIZ_CHOICES := 3
# Marge autour d'une reponse dans son nuage
const THOUGHT_PADDING := Vector2(72, 52)
# Lignes du nuage : touche de clavier, espace avant la reponse, espace entre deux lignes
const KEY_WIDTH := 28.0
const KEY_GAP := 10.0
const ROW_GAP := 14.0
# Hauteur du nuage au-dessus de la tete, et point d'arrivee de la trainee sous le nuage (part de sa largeur)
const CLOUD_LIFT := 60.0
const TRAIL_ARRIVAL := 0.7

var _progress := LevelProgress.new()
var _door_key := DoorKey.new()
var _score := LevelScore.new()
var _door_code := DoorCode.new(DoorCode.random_code(RandomNumberGenerator.new()))
var _reaction := QuizReaction.new()
var _quiz := ColleagueQuiz.new(ColleagueQuiz.pick_question(QuizQuestions.QUESTIONS, RandomNumberGenerator.new()))
var _managers: Array[Node] = []
var _patrolling_managers: Array[Node] = []
var _desks: Array[Node] = []
var _level_number := 0
# Textes du ticket de reussite, tires une fois par niveau
var _suspicion := LevelResult.pick(LevelResult.SUSPICIONS, RandomNumberGenerator.new())
var _spotter := HrWarning.Spotter.WATCHING

@onready var _player: CharacterBody2D = $Player
@onready var _goal: Area2D = $Arrivee
@onready var _key: Area2D = get_node_or_null("Cle")
@onready var _door: StaticBody2D = get_node_or_null("Porte")
@onready var _post_it: Area2D = get_node_or_null("PostIt")
@onready var _code_door: StaticBody2D = get_node_or_null("PorteDigicode")
@onready var _colleague: Area2D = get_node_or_null("Collegue")
@onready var _key_indicator: Label = $Interface/IndicateurCle
@onready var _success_message: Control = $Interface/MessageSucces
@onready var _success_title: Label = $Interface/MessageSucces/Titre
@onready var _success_details: Label = $Interface/MessageSucces/Details
@onready var _success_record: Label = $Interface/MessageSucces/Record
@onready var _success_sign: Label = $Interface/MessageSucces/Plaque
@onready var _success_rank: Label = $Interface/MessageSucces/Rang
@onready var _success_paper: ToiletPaper = $Interface/MessageSucces/Papier
@onready var _success_stamp: Label = $Interface/MessageSucces/Tampon
@onready var _next_button: Button = $Interface/MessageSucces/Boutons/Suivant
@onready var _game_over_message: Control = $Interface/MessageGameOver
@onready var _game_over_details: Label = $Interface/MessageGameOver/Details
@onready var _game_over_stamp: Label = $Interface/MessageGameOver/Titre
@onready var _game_over_sheet: Panel = $Interface/MessageGameOver/Fiche
@onready var _game_over_replay_button: Button = $Interface/MessageGameOver/Boutons/Rejouer
@onready var _game_over_form: Label = $Interface/MessageGameOver/Formulaire
@onready var _photo: TextureRect = $Interface/MessageGameOver/Photo
@onready var _photo_frame: ReferenceRect = $Interface/MessageGameOver/Photo/Cadre
@onready var _photo_caption: Label = $Interface/MessageGameOver/Photo/Legende
@onready var _photo_no_signal: Label = $Interface/MessageGameOver/Photo/PasDeSignal
@onready var _chrono: Label = $Interface/Chrono
@onready var _keypad: Panel = $Interface/Digicode
@onready var _keypad_entry: Label = $Interface/Digicode/Saisie
@onready var _keypad_error: Label = $Interface/Digicode/Erreur
@onready var _quiz_panel: Control = $Interface/Collegue
@onready var _quiz_speech: SpeechBubble = $Interface/Collegue/Dialogue
@onready var _quiz_cloud: SpeechBubble = $Interface/Collegue/Reflexion
@onready var _quiz_title: Label = $Interface/Collegue/Titre
@onready var _quiz_help: Label = $Interface/Collegue/Aide
@onready var _quiz_question: Label = $Interface/Collegue/Question


func _ready() -> void:
	# Decor d'open space en parallaxe, ajoute a tous les niveaux
	if not has_node("Decor"):
		add_child(BACKDROP_SCENE.instantiate())
	_limit_camera_to_walls()
	_managers = _find_in_group("managers")
	_patrolling_managers = _find_in_group("patrolling_managers")
	_add_home_desk()
	_desks = _find_in_group("desks")
	_goal.body_entered.connect(_on_arrivee_body_entered)
	for manager in _managers:
		# Connecte avant le game over pour savoir quel manager a repere le joueur
		manager.body_spotted.connect(_remember_spotter.bind(manager))
		manager.body_spotted.connect(_on_manager_body_spotted)
	if _has_code():
		_post_it.body_exited.connect(_on_post_it_body_exited)
		_post_it.get_node("Code").text = _door_code.code()
	if _colleague:
		_colleague.body_entered.connect(_on_collegue_body_entered)
	_next_button.pressed.connect(next_requested.emit)
	for screen in [_success_message, _game_over_message]:
		screen.get_node("Boutons/Rejouer").pressed.connect(restart_requested.emit)
		screen.get_node("Boutons/Selection").pressed.connect(menu_requested.emit)
	$Interface/MessageSucces/Pied.text = LevelResult.pick(LevelResult.BOSS_NOTES, RandomNumberGenerator.new())
	configure(0, false)


# Le joueur demarre a son bureau : un vrai bureau de travail, dessine derriere lui
func _add_home_desk() -> void:
	if has_node("BureauPerso"):
		return
	var desk: Node2D = HOME_DESK_SCENE.instantiate()
	desk.position = Vector2(_player.position.x, 0)
	add_child(desk)
	move_child(desk, _player.get_index())


# Les murs sont les bords du batiment : au depart le joueur est a gauche de l'ecran
func _limit_camera_to_walls() -> void:
	var camera: Camera2D = _player.get_node("Camera2D")
	var limits := LevelBounds.camera_limits(_wall_rect($MurGauche), _wall_rect($MurDroit))
	camera.limit_left = limits.x
	camera.limit_right = limits.y
	camera.limit_bottom = LevelBounds.camera_bottom(($Sol as Control).get_rect())


func _wall_rect(wall: Node2D) -> Rect2:
	var shape: RectangleShape2D = wall.get_node("CollisionShape2D").shape
	return LevelBounds.wall_rect(wall.position, shape.size)


# Appele par le jeu au chargement : numero du niveau et bouton Next ou Finish
func configure(number: int, is_last: bool) -> void:
	_level_number = number
	_success_title.text = LevelResult.success_title(number) + "\n" + _suspicion
	_next_button.text = LevelResult.next_label(is_last)


# Appele par le jeu au chargement : la photo choisie pour le badge, agrafee a l'avertissement RH
func set_employee_icon(id: String) -> void:
	$Interface/MessageGameOver/PhotoIdentite.icon_id = id
	$BureauPerso/Visuel/Photo.icon_id = id


# Appele par le jeu une fois le score enregistre
func show_best(best: int, is_new: bool) -> void:
	_success_record.text = LevelResult.best_line(best, is_new)
	_success_record.visible = true


# Cherche dans le niveau seulement, pas dans tout l'arbre
func _find_in_group(group: String) -> Array[Node]:
	var found: Array[Node] = []
	for node in find_children("*", "", true, false):
		if node.is_in_group(group):
			found.append(node)
	return found


func _has_key_door() -> bool:
	return _key != null and _door != null


func _has_code() -> bool:
	return _post_it != null and _code_door != null


func _physics_process(delta: float) -> void:
	_score.update(delta)
	_refresh_chrono()
	_update_quiz_reaction(delta)


# Pendant la question, le joueur est bloque et protege ; la reaction qui suit n'est qu'affichee
func _in_conversation() -> bool:
	return _quiz.is_talking()



func _refresh_chrono() -> void:
	_chrono.text = LevelScore.format_time(_score.elapsed())


func _unhandled_input(event: InputEvent) -> void:
	if _in_conversation():
		_quiz_input(event)
	elif _door_code.is_keypad_open():
		_keypad_input(event)
	elif event.is_action_pressed("ui_cancel"):
		# Le meme appui ne doit pas etre retraite par le jeu (sinon la pause se refermerait aussitot)
		get_viewport().set_input_as_handled()
		if _progress.can_move():
			pause_requested.emit()
		else:
			menu_requested.emit()
	elif event.is_action_pressed("restart") and _progress.can_restart():
		restart_requested.emit()
	elif event.is_action_pressed("next_level") and _progress.can_continue():
		next_requested.emit()
	elif event.is_action_pressed("work") and _progress.can_move():
		_press_work()


# Le digicode, le post-it, la porte et la cle passent avant le travail (voir InteractionHint)
func _press_work() -> void:
	var state := _interaction_state()
	match InteractionHint.resolve(state):
		InteractionHint.Action.TYPE_CODE:
			_set_keypad_open(true)
		InteractionHint.Action.READ_CODE:
			_door_code.read()
			_refresh_post_it()
		InteractionHint.Action.OPEN_DOOR, InteractionHint.Action.TAKE_KEY:
			_door_key.interact(state["at_door"], state["on_key"])
			_refresh_door_key()
		_:
			_player.press_work(state["on_desk"])


# Ce qui est a portee du joueur, pour InteractionHint
func _interaction_state() -> Dictionary:
	return {
		"can_act": _progress.can_move() and not _door_code.is_keypad_open() and not _in_conversation(),
		"at_keypad": _has_code() and not _door_code.is_door_open() and _code_door.is_body_near(_player),
		"on_post_it": _has_code() and _post_it.overlaps_body(_player),
		"at_door": _has_key_door() and _door.is_body_near(_player),
		"door_open": _has_key_door() and _door_key.is_door_open(),
		"has_key": _has_key_door() and _door_key.has_key(),
		"on_key": _has_key_door() and _door_key.is_key_on_desk() and _key.overlaps_body(_player),
		"working": _player.is_working(),
		"on_desk": _is_player_on_desk(),
	}




func _refresh_door_key() -> void:
	_key.visible = _door_key.is_key_on_desk()
	_key_indicator.visible = _door_key.has_key()
	if _door_key.is_door_open():
		_door.open()


func _refresh_post_it() -> void:
	_post_it.get_node("Code").visible = _door_code.is_code_shown()


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
			_score.add_wrong_code()
			_attract_patrols(_code_door.position.x, 1.0)
			_keypad_error.visible = true
		DoorCode.Result.RIGHT:
			_code_door.open()
			_player.set_busy(false)


func _attract_patrols(target_x: float, speed_factor: float) -> void:
	for patrol in _patrolling_managers:
		patrol.attract(target_x, speed_factor)


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
	for i in QUIZ_CHOICES:
		var label := _quiz_choice_label(i)
		label.text = question["choices"][i]
		label.reset_size()
	_quiz_panel.visible = true
	_place_quiz_bubbles()
	# La camera suit le joueur : on replace les bulles une fois qu'elle s'est posee
	_place_quiz_bubbles.call_deferred()


# Question dans une bulle de dialogue au-dessus du collegue (vers la droite),
# les trois reponses dans un nuage de reflexion au-dessus du joueur
func _place_quiz_bubbles() -> void:
	var screen := get_viewport().get_visible_rect().size
	var visual: Control = _colleague.get_node("Visuel")
	var colleague_top := _colleague.get_global_transform_with_canvas() * Vector2(visual.position.x + visual.size.x / 2.0, visual.position.y)
	var player_top := _player.get_global_transform_with_canvas() * Vector2(0, -PLAYER_HALF_HEIGHT)
	var speech := SpeechBubble.place(colleague_top, _quiz_speech.size, screen, SpeechBubble.Side.RIGHT)
	_quiz_speech.position = speech.position
	_quiz_speech.tail_x = SpeechBubble.tail_offset(colleague_top, speech)
	_quiz_title.position = speech.position + Vector2(16, 10)
	_quiz_question.position = speech.position + Vector2(16, 34)
	_quiz_help.position = speech.position + Vector2(16, speech.size.y - 26)
	# Le nuage prend la taille des trois lignes (touche, reponse) et des separateurs
	var row_height := 0.0
	var text_width := 0.0
	for i in QUIZ_CHOICES:
		var label_size := _quiz_choice_label(i).size
		row_height = maxf(row_height, maxf(label_size.y, _quiz_key(i).size.y))
		text_width = maxf(text_width, label_size.x)
	var content := Vector2(KEY_WIDTH + KEY_GAP + text_width, row_height * QUIZ_CHOICES + ROW_GAP * (QUIZ_CHOICES - 1))
	_quiz_cloud.size = content + THOUGHT_PADDING
	var cloud := SpeechBubble.place(player_top - Vector2(0, CLOUD_LIFT), _quiz_cloud.size, screen, SpeechBubble.Side.LEFT)
	# Joueur et collegue se touchent : le nuage se range a cote du dialogue
	cloud = SpeechBubble.avoid(cloud, speech, screen)
	_quiz_cloud.position = cloud.position
	var origin := cloud.position + THOUGHT_PADDING / 2.0
	for i in QUIZ_CHOICES:
		var top := origin.y + i * (row_height + ROW_GAP)
		var key := _quiz_key(i)
		var label := _quiz_choice_label(i)
		key.position = Vector2(origin.x, top + (row_height - key.size.y) / 2.0)
		label.position = Vector2(origin.x + KEY_WIDTH + KEY_GAP, top + (row_height - label.size.y) / 2.0)
		if i < QUIZ_CHOICES - 1:
			var separator: Control = get_node("Interface/Collegue/Separateur%d" % (i + 1))
			separator.size.x = content.x
			separator.position = Vector2(origin.x, top + row_height + (ROW_GAP - separator.size.y) / 2.0)
	# Une trainee droite de ronds monte de la tete jusque sous le nuage
	var trail: ThoughtTrail = $Interface/Collegue/Pensee
	trail.from = player_top
	var arrival := minf(SpeechBubble.tail_offset(player_top, cloud), cloud.size.x * TRAIL_ARRIVAL)
	trail.to = Vector2(cloud.position.x + arrival, cloud.end.y)


func _quiz_key(index: int) -> Label:
	return get_node("Interface/Collegue/Touche%d" % (index + 1))


func _quiz_choice_label(index: int) -> Label:
	return get_node("Interface/Collegue/Choix%d" % (index + 1))


# Pendant la question, seules les touches 1 a 3 comptent
func _quiz_input(event: InputEvent) -> void:
	if _quiz.is_talking() and event is InputEventKey and event.pressed and not event.echo:
		var choice := _digit_of(event) - 1
		var result := _quiz.answer(choice)
		if result == ColleagueQuiz.Result.WRONG:
			_score.add_wrong_answer()
			_attract_patrols(_colleague.position.x, ManagerPatrol.RUSH_FACTOR)
		if result != ColleagueQuiz.Result.IGNORED:
			_start_quiz_reaction(choice, result)
	get_viewport().set_input_as_handled()


# La reponse choisie passe en vert (rebond) ou en rouge barre (secousse), les autres s'estompent
func _start_quiz_reaction(choice: int, result: ColleagueQuiz.Result) -> void:
	_reaction.start(result)
	_player.set_busy(false)
	for i in QUIZ_CHOICES:
		var style := QuizReaction.row_style(i, choice, result)
		var label := _quiz_choice_label(i)
		label.add_theme_color_override("font_color", style["color"])
		label.modulate.a = style["alpha"]
		_quiz_key(i).modulate.a = style["alpha"]
		var strike := _quiz_strike(i)
		strike.visible = style["struck"]
		strike.size.x = label.size.x
		strike.position = label.position + Vector2(0, label.size.y / 2.0)
	for node in _quiz_cloud_nodes():
		if result == ColleagueQuiz.Result.RIGHT:
			UiFx.hop(node)
		else:
			UiFx.shake(node)


func _update_quiz_reaction(delta: float) -> void:
	if not _reaction.is_active():
		return
	_reaction.update(delta)
	if not _reaction.is_active():
		_quiz_panel.visible = false
		for i in QUIZ_CHOICES:
			_quiz_choice_label(i).remove_theme_color_override("font_color")
			_quiz_choice_label(i).modulate.a = 1.0
			_quiz_key(i).modulate.a = 1.0
			_quiz_strike(i).visible = false


# Tout ce qui forme le nuage de reponses, anime d'un seul bloc
func _quiz_cloud_nodes() -> Array[Control]:
	var nodes: Array[Control] = [_quiz_cloud, $Interface/Collegue/Pensee]
	for i in QUIZ_CHOICES:
		nodes.append_array([_quiz_key(i), _quiz_choice_label(i), _quiz_strike(i)])
		if i < QUIZ_CHOICES - 1:
			nodes.append(get_node("Interface/Collegue/Separateur%d" % (i + 1)))
	return nodes


func _quiz_strike(index: int) -> ColorRect:
	return get_node("Interface/Collegue/Rature%d" % (index + 1))


func _on_post_it_body_exited(body: Node2D) -> void:
	if body != _player:
		return
	_door_code.stop_reading()
	_refresh_post_it()


func _is_player_on_desk() -> bool:
	for desk: Area2D in _desks:
		if desk.overlaps_body(_player):
			return true
	return false


func _on_arrivee_body_entered(body: Node2D) -> void:
	if body != _player:
		return
	_progress.reach_goal()
	_freeze_level()
	_success_details.text = LevelResult.details(LevelScore.format_time(_score.elapsed()), _score.score())
	_success_rank.text = LevelResult.rank_line(_score.score())
	_success_message.visible = _progress.can_continue()
	if _progress.can_continue():
		_next_button.call_deferred("grab_focus")
		UiFx.pop_in(_success_sign)
		_print_receipt()
		succeeded.emit(_score.score())


# Le ticket sort du distributeur, chaque ligne apparait quand le papier l'atteint,
# puis le tampon tombe au bas de la bande
func _print_receipt() -> void:
	var lines: Array[Control] = [_success_title, _success_details, _success_rank, _success_record, $Interface/MessageSucces/Pied]
	_success_paper.unroll(lines)
	_success_stamp.modulate.a = 0.0
	var tween := _success_stamp.create_tween()
	tween.tween_interval(ToiletPaper.UNROLL_DURATION)
	tween.tween_callback(UiFx.stamp.bind(_success_stamp, STAMP_ANGLE))


func _remember_spotter(body: Node2D, manager: Node) -> void:
	if body == _player and _progress.can_move():
		_spotter = HrWarning.Spotter.PATROLLING if manager in _patrolling_managers else HrWarning.Spotter.WATCHING


func _on_manager_body_spotted(body: Node2D) -> void:
	if body != _player or _player.is_working() or _in_conversation():
		return
	# Une fois le niveau fini, une autre detection ne doit rien changer
	if not _progress.can_move():
		return
	_progress.fail()
	_freeze_level()
	_take_surveillance_shot()
	_fill_hr_warning()
	_game_over_message.visible = _progress.is_game_over()
	if _progress.is_game_over():
		_game_over_replay_button.call_deferred("grab_focus")
		UiFx.stamp(_game_over_stamp, STAMP_ANGLE)
		UiFx.shake(_game_over_sheet)


func _fill_hr_warning() -> void:
	var has_key := _has_key_door() and _door_key.has_key()
	var knows_code := _has_code() and _door_code.has_read_code()
	_game_over_form.text = HrWarning.form_text(_spotter, has_key, knows_code, _level_number)
	var time_text := LevelScore.format_time(_score.elapsed())
	_game_over_details.text = HrWarning.stats(time_text, _score.wrong_codes(), _score.wrong_answers())
	_photo_caption.text = SurveillanceShot.caption(time_text)


# Derniere image dessinee (donc sans l'ecran de game over), recadree sur le joueur.
# Sans rendu (headless), la photo affiche NO SIGNAL.
func _take_surveillance_shot() -> void:
	var image: Image = null
	if DisplayServer.get_name() != "headless":
		image = get_viewport().get_texture().get_image()
	var has_image := image != null and not image.is_empty()
	_photo_no_signal.visible = not has_image
	_photo_frame.visible = has_image
	if not has_image:
		_photo.texture = null
		return
	var focus := _player.get_global_transform_with_canvas().origin
	var crop := SurveillanceShot.crop_rect(focus, image.get_size(), SURVEILLANCE_CROP)
	_photo.texture = ImageTexture.create_from_image(image.get_region(crop))
	var center := SurveillanceShot.frame_position(focus, crop, _photo.size)
	_photo_frame.position = center - _photo_frame.size / 2.0


func _freeze_level() -> void:
	_score.stop()
	_refresh_chrono()
	_set_keypad_open(false)
	_player.set_physics_process(_progress.can_move())
	for manager in _managers:
		manager.set_physics_process(_progress.can_move())
