extends CharacterBody2D


func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = PlayerMovement.horizontal_velocity(direction)
	move_and_slide()
