class_name UiFx
extends RefCounted

# Petites animations d'interface (affichage seulement). A ne pas utiliser sur
# l'enfant d'un Container : il remet l'echelle et la rotation a zero.

const POP_DURATION := 0.35
const STAMP_DURATION := 0.25
const SHAKE_DURATION := 0.3
const SHAKE_DISTANCE := 12.0
const SWING_DURATION := 2.4


# Apparait en grossissant depuis le centre, avec un petit rebond
static func pop_in(control: Control, delay := 0.0) -> Tween:
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2.ZERO
	var tween := control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE, POP_DURATION) \
		.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return tween


# Tampon qui s'abat : part grand et transparent, finit penche
static func stamp(control: Control, angle: float) -> Tween:
	control.pivot_offset = control.size / 2.0
	control.scale = Vector2(2.5, 2.5)
	control.rotation = 0.0
	control.modulate.a = 0.0
	var tween := control.create_tween().set_parallel()
	tween.tween_property(control, "scale", Vector2.ONE, STAMP_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(control, "rotation", angle, STAMP_DURATION)
	tween.tween_property(control, "modulate:a", 1.0, STAMP_DURATION * 0.5)
	return tween


# Courte secousse horizontale, puis retour a la position de depart
static func shake(control: Control) -> Tween:
	var start := control.position
	var step := SHAKE_DURATION / 6.0
	var tween := control.create_tween()
	for offset in [SHAKE_DISTANCE, -SHAKE_DISTANCE, SHAKE_DISTANCE * 0.6, -SHAKE_DISTANCE * 0.6, SHAKE_DISTANCE * 0.3]:
		tween.tween_property(control, "position", start + Vector2(offset, 0), step)
	tween.tween_property(control, "position", start, step)
	return tween


# Balancement sans fin autour d'un pivot (le haut d'un cordon, par exemple)
static func swing(control: Control, pivot: Vector2, angle: float) -> Tween:
	control.pivot_offset = pivot
	var tween := control.create_tween().set_loops()
	tween.tween_property(control, "rotation", angle, SWING_DURATION / 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "rotation", -angle, SWING_DURATION / 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
