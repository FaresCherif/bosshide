extends GutTest


func test_direction_gauche_donne_vitesse_negative() -> void:
	assert_eq(PlayerMovement.horizontal_velocity(-1.0, 300.0), -300.0, "Vers la gauche, la vitesse doit etre negative")


func test_direction_droite_donne_vitesse_positive() -> void:
	assert_eq(PlayerMovement.horizontal_velocity(1.0, 300.0), 300.0, "Vers la droite, la vitesse doit etre positive")


func test_sans_direction_vitesse_nulle() -> void:
	assert_eq(PlayerMovement.horizontal_velocity(0.0, 300.0), 0.0, "Sans direction, le joueur doit rester immobile")
