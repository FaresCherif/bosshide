extends GutTest


func test_au_depart_l_icone_est_la_silhouette_classique() -> void:
	assert_eq(EmployeeProfile.new().icon_id(), "classic")


func test_choisir_une_icone_connue() -> void:
	var profile := EmployeeProfile.new()
	assert_true(profile.select("mug"), "Une icone connue doit etre acceptee")
	assert_eq(profile.icon_id(), "mug")


func test_une_icone_inconnue_est_refusee() -> void:
	var profile := EmployeeProfile.new()
	profile.select("tie")
	assert_false(profile.select("dragon"), "Une icone inconnue doit etre refusee")
	assert_eq(profile.icon_id(), "tie", "Le choix precedent doit rester")


func test_dix_icones_aux_ids_uniques_et_nommees() -> void:
	var ids := {}
	for icon in EmployeeProfile.ICONS:
		ids[icon["id"]] = true
		assert_ne(EmployeeProfile.icon_name(icon["id"]), "", icon["id"] + " doit avoir un nom")
	assert_eq(EmployeeProfile.ICONS.size(), 10, "Il doit y avoir 10 icones")
	assert_eq(ids.size(), 10, "Les ids doivent etre uniques")


func test_chaque_icone_peut_etre_dessinee() -> void:
	for icon in EmployeeProfile.ICONS:
		assert_true(IdPhoto.supports(icon["id"]), icon["id"] + " doit avoir un dessin")
