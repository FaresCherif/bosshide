@tool
class_name OfficeBackdrop
extends Control

# Decor d'open space derriere les niveaux, dessine en formes simples (affichage seulement).
# Un motif de TILE_WIDTH px que la parallaxe repete. Les y sont ceux du monde : le haut
# du sol des niveaux est a FLOOR_Y. Couleurs sombres et desaturees pour que les
# elements de jeu (rectangles de couleur) ressortent.

const TILE_WIDTH := 1200.0
const FLOOR_Y := 32.0
const TOP_Y := -700.0
# Bas du plafond : le haut de l'ecran montre des dalles et des neons, pas un aplat
const CEILING_Y := -480.0
const BOTTOM_Y := 600.0

const WALL_COLOR := Color(0.36, 0.37, 0.4, 1)
const CEILING_COLOR := Color(0.27, 0.28, 0.31, 1)
const CARPET_COLOR := Color(0.2, 0.23, 0.29, 1)
const SKY_TOP := Color(0.22, 0.33, 0.48, 1)
const SKY_BOTTOM := Color(0.38, 0.5, 0.62, 1)
const FRAME_COLOR := Color(0.2, 0.2, 0.23, 1)
const PLANT_COLOR := Color(0.18, 0.35, 0.22, 1)
const PARTITION_COLOR := Color(0.3, 0.31, 0.34, 1)
const POSTER_COLOR := Color(0.55, 0.52, 0.45, 1)
const INK := Color(0.15, 0.15, 0.17, 1)


# Elements accroches au mur ou poses devant, dans le motif (y du monde)
static func props() -> Array[Dictionary]:
	return [
		{"kind": "neon", "rect": Rect2(150, -470, 220, 10)},
		{"kind": "neon", "rect": Rect2(780, -470, 220, 10)},
		{"kind": "window", "rect": Rect2(60, -420, 260, 330)},
		{"kind": "poster_synergy", "rect": Rect2(380, -330, 110, 140)},
		{"kind": "clock", "rect": Rect2(540, -400, 70, 70)},
		{"kind": "window", "rect": Rect2(660, -420, 260, 330)},
		{"kind": "poster_goals", "rect": Rect2(980, -330, 130, 110)},
		{"kind": "partition", "rect": Rect2(120, -40, 360, 72)},
		{"kind": "plant", "rect": Rect2(560, -70, 60, 102)},
		{"kind": "partition", "rect": Rect2(700, -40, 360, 72)},
	]


func _ready() -> void:
	position.y = TOP_Y
	size = Vector2(TILE_WIDTH, BOTTOM_Y - TOP_Y)


func _draw() -> void:
	# On dessine avec les y du monde
	draw_set_transform(Vector2(0, -TOP_Y))
	draw_rect(Rect2(0, TOP_Y, TILE_WIDTH, CEILING_Y - TOP_Y), CEILING_COLOR)
	# Dalles de faux plafond
	var tile := 100.0
	var y := CEILING_Y - tile
	while y > TOP_Y:
		draw_line(Vector2(0, y), Vector2(TILE_WIDTH, y), CEILING_COLOR.darkened(0.2), 2.0)
		y -= tile
	var x := 0.0
	while x < TILE_WIDTH:
		draw_line(Vector2(x, TOP_Y), Vector2(x, CEILING_Y), CEILING_COLOR.darkened(0.2), 2.0)
		x += tile
	draw_rect(Rect2(0, CEILING_Y, TILE_WIDTH, FLOOR_Y - CEILING_Y), WALL_COLOR)
	draw_rect(Rect2(0, CEILING_Y, TILE_WIDTH, 6), CEILING_COLOR.darkened(0.3))
	draw_rect(Rect2(0, FLOOR_Y - 8, TILE_WIDTH, 8), WALL_COLOR.darkened(0.35))
	draw_rect(Rect2(0, FLOOR_Y, TILE_WIDTH, BOTTOM_Y - FLOOR_Y), CARPET_COLOR)
	for prop in props():
		var rect: Rect2 = prop["rect"]
		match prop["kind"]:
			"neon":
				draw_rect(rect.grow(6), Color(0.85, 0.9, 1, 0.08))
				draw_rect(rect, Color(0.8, 0.84, 0.88, 1))
			"window":
				_draw_window(rect)
			"poster_synergy":
				_draw_poster(rect, "SYNERGY")
				draw_circle(rect.get_center() + Vector2(0, 18), 22, Color(0.3, 0.38, 0.55, 1))
			"poster_goals":
				_draw_poster(rect, "Q4 GOALS")
				var chart := PackedVector2Array()
				for i in 5:
					chart.append(rect.position + Vector2(15 + i * 25, 45 + i * i * 2.5))
				draw_polyline(chart, Color(0.7, 0.2, 0.2, 1), 3.0)
			"clock":
				var center := rect.get_center()
				draw_circle(center, rect.size.x / 2.0, FRAME_COLOR)
				draw_circle(center, rect.size.x / 2.0 - 4, Color(0.75, 0.75, 0.72, 1))
				draw_line(center, center + Vector2(0, -22), INK, 3.0)
				draw_line(center, center + Vector2(16, 6), INK, 3.0)
			"partition":
				draw_rect(rect, PARTITION_COLOR)
				draw_rect(Rect2(rect.position, Vector2(rect.size.x, 6)), PARTITION_COLOR.lightened(0.15))
			"plant":
				var pot := Rect2(rect.position + Vector2(12, 62), Vector2(36, 40))
				draw_rect(pot, Color(0.4, 0.3, 0.24, 1))
				for leaf in [Vector2(30, 20), Vector2(14, 40), Vector2(46, 38), Vector2(30, 48)]:
					draw_circle(rect.position + leaf, 16, PLANT_COLOR)


func _draw_window(rect: Rect2) -> void:
	draw_rect(rect, FRAME_COLOR)
	var glass := rect.grow(-8)
	var half := Rect2(glass.position, Vector2(glass.size.x, glass.size.y / 2.0))
	draw_rect(half, SKY_TOP)
	draw_rect(Rect2(glass.position + Vector2(0, glass.size.y / 2.0), half.size), SKY_BOTTOM)
	# Immeubles au loin
	for building: Vector3 in [Vector3(0.05, 0.45, 0.2), Vector3(0.3, 0.25, 0.15), Vector3(0.5, 0.55, 0.22), Vector3(0.78, 0.35, 0.18)]:
		var height: float = glass.size.y * building.y
		draw_rect(Rect2(glass.position.x + glass.size.x * building.x, glass.end.y - height, glass.size.x * building.z, height), Color(0.25, 0.3, 0.38, 1))
	draw_rect(Rect2(rect.get_center().x - 4, rect.position.y, 8, rect.size.y), FRAME_COLOR)


func _draw_poster(rect: Rect2, title: String) -> void:
	draw_rect(rect, POSTER_COLOR)
	draw_rect(rect, INK, false, 2.0)
	draw_string(get_theme_default_font(), rect.position + Vector2(0, 26), title, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 18, INK)
