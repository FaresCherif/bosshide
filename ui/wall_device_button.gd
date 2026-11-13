@tool
class_name WallDeviceButton
extends GlowButton

# Bouton du menu dessine comme un objet fixe au mur, avec le halo de GlowButton. Le fond vient du theme
# (TimeClockButton, ClipboardButton, AlarmButton) ; ce script ajoute les details
# dans le haut de l'objet, au-dessus du texte (affichage seulement).

const DEVICES := ["time_clock", "clipboard", "alarm"]

@export_enum("time_clock", "clipboard", "alarm") var device := "time_clock":
	set(value):
		device = value if DEVICES.has(value) else "time_clock"
		queue_redraw()


func _draw() -> void:
	match device:
		"time_clock":
			_draw_time_clock()
		"clipboard":
			_draw_clipboard()
		"alarm":
			_draw_alarm()
	# Halo d'interaction par-dessus l'objet
	super()


# Ecran IN, voyant vert et fente a carte
func _draw_time_clock() -> void:
	var screen := Rect2(16, 12, 64, 26)
	draw_rect(screen, Color(0.08, 0.12, 0.1, 1))
	draw_string(get_theme_font("font"), Vector2(screen.position.x, screen.end.y - 6), "IN",
		HORIZONTAL_ALIGNMENT_CENTER, screen.size.x, 20, Color(0.35, 0.95, 0.45, 1))
	# Le voyant clignote doucement
	var lit := fmod(Time.get_ticks_msec() / 1000.0, 1.2) < 0.8
	draw_circle(Vector2(size.x - 26, 25), 6.0, Color(0.3, 0.85, 0.4, 1) if lit else Color(0.15, 0.35, 0.2, 1))
	draw_rect(Rect2(16, 46, size.x - 32, 6), Color(0.15, 0.15, 0.18, 1))


# Pince metallique en haut de la planche
func _draw_clipboard() -> void:
	var metal := Color(0.72, 0.74, 0.78, 1)
	draw_rect(Rect2(size.x / 2.0 - 32, -6, 64, 24), metal.darkened(0.25))
	draw_rect(Rect2(size.x / 2.0 - 30, -4, 60, 20), metal)
	draw_rect(Rect2(size.x / 2.0 - 16, 2, 32, 7), metal.darkened(0.4))


# Mention BREAK GLASS et vitre autour du texte
func _draw_alarm() -> void:
	draw_string(get_theme_font("font"), Vector2(0, 30), "BREAK GLASS",
		HORIZONTAL_ALIGNMENT_CENTER, size.x, 18, Color(1, 1, 1, 1))
	var glass := Rect2(14, 42, size.x - 28, size.y - 54)
	draw_rect(glass, Color(1, 1, 1, 0.12))
	draw_rect(glass, Color(1, 1, 1, 0.7), false, 2.0)
	draw_line(glass.position + Vector2(10, 8), glass.position + Vector2(24, 22), Color(1, 1, 1, 0.5), 2.0)
