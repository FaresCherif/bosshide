extends GutTest


func test_les_cases_a_cocher() -> void:
	assert_eq(HrWarning.checkbox(true, "Not at desk"), "[X] Not at desk")
	assert_eq(HrWarning.checkbox(false, "Not at desk"), "[  ] Not at desk")


func test_repere_par_le_manager_fixe() -> void:
	assert_eq(HrWarning.spotted_by(HrWarning.Spotter.WATCHING), ["[X] The boss (watching)", "[  ] The boss (patrolling)"])


func test_repere_par_le_patrouilleur() -> void:
	assert_eq(HrWarning.spotted_by(HrWarning.Spotter.PATROLLING), ["[  ] The boss (watching)", "[X] The boss (patrolling)"])


func test_les_motifs_suivent_l_etat_du_joueur() -> void:
	assert_eq(HrWarning.reasons(false, false), [
		"[X] Not at desk",
		"[  ] In possession of a stolen key",
		"[  ] Knows confidential codes",
	])
	assert_eq(HrWarning.reasons(true, true), [
		"[X] Not at desk",
		"[X] In possession of a stolen key",
		"[X] Knows confidential codes",
	])


func test_les_statistiques() -> void:
	assert_eq(HrWarning.stats("00:42.3", 1, 2), "Time: 00:42.3 - Wrong codes: 1 - Wrong answers: 2")


func test_une_sanction_fixe_par_niveau() -> void:
	assert_eq(HrWarning.sanction(1), HrWarning.SANCTIONS[0])
	assert_eq(HrWarning.sanction(2), HrWarning.SANCTIONS[1])
	assert_ne(HrWarning.sanction(1), HrWarning.sanction(2), "Deux niveaux voisins n'ont pas la meme sanction")
	assert_eq(HrWarning.sanction(HrWarning.SANCTIONS.size() + 1), HrWarning.SANCTIONS[0], "Les sanctions reviennent au debut")
	assert_eq(HrWarning.sanction(0), HrWarning.SANCTIONS[0], "Un niveau lance seul prend la premiere sanction")


func test_le_formulaire_assemble_les_sections() -> void:
	var text := HrWarning.form_text(HrWarning.Spotter.PATROLLING, true, false, 2)
	assert_string_contains(text, "Spotted by:\n[  ] The boss (watching)\n[X] The boss (patrolling)")
	assert_string_contains(text, "Reason:\n[X] Not at desk\n[X] In possession of a stolen key\n[  ] Knows confidential codes")
	assert_string_contains(text, "Sanction: " + HrWarning.SANCTIONS[1])


func test_temps_ecoule_remplace_le_bloc_repere_par() -> void:
	var text := HrWarning.form_text(HrWarning.Spotter.TIME_UP, false, true, 9)
	assert_false(text.contains("Spotted by"), "Personne n'a repere le joueur")
	assert_string_contains(text, "Shift over, still not at desk")
	assert_string_contains(text, "Reason:\n[X] Not at desk\n[  ] In possession of a stolen key\n[X] Knows confidential codes")
	assert_string_contains(text, "Sanction: " + HrWarning.sanction(9))


func test_le_tampon_depend_de_la_cause() -> void:
	assert_eq(HrWarning.stamp_text(HrWarning.Spotter.WATCHING), "BUSTED!")
	assert_eq(HrWarning.stamp_text(HrWarning.Spotter.PATROLLING), "BUSTED!")
	assert_eq(HrWarning.stamp_text(HrWarning.Spotter.TIME_UP), "TOO LATE!")


func test_une_sanction_differente_pour_chacun_des_dix_niveaux() -> void:
	var sanctions := {}
	for number in range(1, 11):
		sanctions[HrWarning.sanction(number)] = true
	assert_eq(sanctions.size(), 10, "Chaque niveau a sa propre sanction")
