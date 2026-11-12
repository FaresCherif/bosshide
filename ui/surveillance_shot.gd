class_name SurveillanceShot
extends RefCounted

# Calculs de la capture de camera de surveillance du game over (sans l'arbre)


# Rectangle centre sur le joueur, recale pour rester dans l'image
static func crop_rect(focus: Vector2, image_size: Vector2i, crop_size: Vector2i) -> Rect2i:
	var size := crop_size.min(image_size)
	var top_left := Vector2i(focus.round()) - size / 2
	top_left = top_left.clamp(Vector2i.ZERO, image_size - size)
	return Rect2i(top_left, size)


# Position du joueur dans la photo affichee, une fois la capture mise a l'echelle
static func frame_position(focus: Vector2, crop: Rect2i, display_size: Vector2) -> Vector2:
	return (focus - Vector2(crop.position)) * display_size / Vector2(crop.size)


static func caption(time_text: String) -> String:
	return "CAM 03 - REC %s" % time_text
