extends StaticBody2D

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _zone: Area2D = $Zone


# Le joueur est colle a la porte, d'un cote ou de l'autre
func is_body_near(body: Node2D) -> bool:
	return _zone.overlaps_body(body)


func open() -> void:
	visible = false
	_shape.set_deferred("disabled", true)
