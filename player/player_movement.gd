class_name PlayerMovement
extends RefCounted

const DEFAULT_SPEED := 300.0


# Vitesse horizontale pour une direction entre -1 (gauche) et 1 (droite)
static func horizontal_velocity(direction: float, speed: float = DEFAULT_SPEED) -> float:
	return direction * speed
