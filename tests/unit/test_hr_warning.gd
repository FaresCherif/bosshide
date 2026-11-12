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
