class_name LevelBounds
extends RefCounted

# Les murs de gauche et de droite sont les bords du batiment : la camera ne montre
# rien au-dela (calculs sans l'arbre)


# Bande visible sous le sol : aucune, le sol est le bas de l'ecran
const CARPET_MARGIN := 0


# Limite basse de la camera : juste sous le sol, pour ne pas montrer de grand vide
static func camera_bottom(floor_rect: Rect2) -> int:
	return int(floor_rect.end.y) + CARPET_MARGIN


static func wall_rect(center: Vector2, size: Vector2) -> Rect2:
	return Rect2(center - size / 2.0, size)


# Limites horizontales de la camera : bord exterieur de chaque mur
static func camera_limits(left_wall: Rect2, right_wall: Rect2) -> Vector2i:
	return Vector2i(int(left_wall.position.x), int(right_wall.end.x))
