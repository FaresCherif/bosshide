extends GutTest

const THEME_PATH := "res://ui/theme.tres"


func _theme() -> Theme:
	return load(THEME_PATH)


func test_le_theme_est_celui_du_projet() -> void:
	assert_eq(ProjectSettings.get_setting("gui/theme/custom"), THEME_PATH, "Toute l'interface doit utiliser le theme")
	assert_true(_theme() is Theme, "Le theme doit se charger")


func test_la_police_par_defaut_est_ecrite_a_la_main() -> void:
	var font: FontFile = _theme().default_font
	assert_not_null(font, "Le theme doit avoir une police par defaut")
	assert_string_contains(font.resource_path, "PatrickHand", "La police par defaut doit etre Patrick Hand")


func test_les_boutons_ont_tous_leurs_styles() -> void:
	for style in ["normal", "hover", "pressed", "focus", "disabled"]:
		assert_true(_theme().has_stylebox(style, "Button"), "Le bouton doit avoir le style " + style)


func test_les_variations_de_texte_existent() -> void:
	for variation in ["HudLabel", "TitleLabel", "StampLabel", "VacantLabel"]:
		assert_eq(_theme().get_type_variation_base(variation), &"Label", variation + " doit etre une variation de Label")


func test_les_titres_utilisent_le_marqueur() -> void:
	var font: Font = _theme().get_font("font", "TitleLabel")
	assert_string_contains(font.resource_path, "PermanentMarker", "Les titres doivent etre au marqueur")


func test_le_bouton_post_it_ligne_existe() -> void:
	assert_eq(_theme().get_type_variation_base("StickyButton"), &"Button", "StickyButton doit etre une variation de Button")
	var normal: StyleBox = _theme().get_stylebox("normal", "StickyButton")
	assert_true(normal is RuledStickyStyle, "Le post-it de niveau doit etre ligne")
	assert_eq(normal.bg_color, Color(1, 0.878, 0.4, 1), "Le post-it doit etre jaune")
	var disabled: RuledStickyStyle = _theme().get_stylebox("disabled", "StickyButton")
	assert_lt(disabled.bg_color.s, normal.bg_color.s, "Un post-it verrouille doit etre plus pale")


func test_les_anciennes_variations_du_post_it_ont_disparu() -> void:
	for variation in ["StickyPanel", "MemoButton"]:
		assert_eq(_theme().get_type_variation_base(variation), &"", variation + " ne sert plus")
