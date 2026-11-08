extends CharacterBody2D

const NORMAL_COLOR := Color(0.25, 0.65, 0.95, 1)
const WORKING_COLOR := Color(0.95, 0.85, 0.3, 1)

var _work := PlayerWork.new()

@onready var _rectangle: ColorRect = $Rectangle


func _unhandled_input(event: InputEvent) -> void:
	# Seul un nouvel appui compte : une touche deja maintenue n'arrete pas le travail
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		_work.stop()
		_refresh_display()


func _physics_process(_delta: float) -> void:
	var direction := _work.allowed_direction(Input.get_axis("move_left", "move_right"))
	velocity.x = PlayerMovement.horizontal_velocity(direction)
	move_and_slide()


func is_working() -> bool:
	return _work.is_working()


func press_work(on_desk: bool) -> void:
	_work.press_work(on_desk)
	_refresh_display()


func set_busy(busy: bool) -> void:
	_work.set_busy(busy)


func _refresh_display() -> void:
	_rectangle.color = WORKING_COLOR if _work.is_working() else NORMAL_COLOR
