extends GutTest


func test_le_titre_de_reussite_donne_le_numero_du_niveau() -> void:
	assert_eq(LevelResult.success_title(3), "Level 3 complete!")


func test_sans_numero_le_titre_reste_generique() -> void:
	assert_eq(LevelResult.success_title(0), "Level complete!", "Un niveau lance seul n'a pas de numero")


func test_les_details_donnent_le_temps_et_le_score() -> void:
	assert_eq(LevelResult.details("00:32.4", 676), "Time: 00:32.4 - Score: 676")


func test_le_temps_seul_pour_le_game_over() -> void:
	assert_eq(LevelResult.time_only("00:12.0"), "Time: 00:12.0")
	assert_false(LevelResult.time_only("00:12.0").contains("Score"), "Le game over ne doit pas afficher de score")


func test_un_nouveau_record_est_signale() -> void:
	assert_eq(LevelResult.best_line(780, true), "New best! Best: 780")


func test_sans_nouveau_record_seul_le_meilleur_score_est_affiche() -> void:
	assert_eq(LevelResult.best_line(780, false), "Best: 780")


func test_le_bouton_suivant_devient_finish_au_dernier_niveau() -> void:
	assert_eq(LevelResult.next_label(false), "Next mission")
	assert_eq(LevelResult.next_label(true), "Clock out")


func test_le_rang_suit_le_score() -> void:
	assert_eq(LevelResult.rank(1000), "Toilet Ninja")
	assert_eq(LevelResult.rank(900), "Toilet Ninja")
	assert_eq(LevelResult.rank(899), "Professional Slacker")
	assert_eq(LevelResult.rank(700), "Professional Slacker")
	assert_eq(LevelResult.rank(699), "Coffee Break Specialist")
	assert_eq(LevelResult.rank(500), "Coffee Break Specialist")
	assert_eq(LevelResult.rank(499), "Overworked Intern")
	assert_eq(LevelResult.rank(250), "Overworked Intern")
	assert_eq(LevelResult.rank(249), "Employee of the Month")
	assert_eq(LevelResult.rank(0), "Employee of the Month", "Le pire score est le chouchou du patron")


func test_la_ligne_du_rang() -> void:
	assert_eq(LevelResult.rank_line(950), "Rank: Toilet Ninja")


func test_le_patron_a_plusieurs_soupcons_et_notes() -> void:
	assert_gte(LevelResult.SUSPICIONS.size(), 3, "Il faut de la variete sous le titre")
	assert_gte(LevelResult.BOSS_NOTES.size(), 3, "Il faut de la variete dans les notes du patron")
	for note: String in LevelResult.BOSS_NOTES:
		assert_true(note.begins_with("Boss's note: "), "Chaque note est signee par le patron : " + note)


func test_le_tirage_reste_dans_la_liste_et_varie() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var seen := {}
	for i in 50:
		var line := LevelResult.pick(LevelResult.SUSPICIONS, rng)
		assert_has(LevelResult.SUSPICIONS, line)
		seen[line] = true
	assert_gt(seen.size(), 1, "Le tirage doit varier d'un niveau a l'autre")


func test_le_tampon_dit_qu_il_n_y_a_pas_de_preuve() -> void:
	assert_eq(LevelResult.APPROVAL_STAMP, "NO EVIDENCE")
