@tool
class_name GlowButton
extends Button

# Bouton qui se signale comme interactif : halo jaune qui pulse doucement au repos
# et s'allume au survol, curseur en main (affichage seulement)

const IDLE_MIN := 0.15
const IDLE_MAX := 0.45
const PULSE_SPEED := 2.2
const GLOW_COLOR := Color(1, 0.85, 0.2)
const GLOW_MARGIN := 5.0


static func glow_alpha(time: float, hovered: bool) -> float:
	if hovered:
		return 1.0
	return IDLE_MIN + (IDLE_MAX - IDLE_MIN) * (0.5 + 0.5 * sin(time * PULSE_SPEED))


func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _process(_delta: float) -> void:
	if is_visible_in_tree():
		queue_redraw()


func _draw() -> void:
	if disabled:
		return
	var alpha := glow_alpha(Time.get_ticks_msec() / 1000.0, is_hovered())
	var halo := Rect2(-Vector2.ONE * GLOW_MARGIN, size + Vector2.ONE * GLOW_MARGIN * 2.0)
	draw_rect(halo, Color(GLOW_COLOR, alpha), false, 4.0)
