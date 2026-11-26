extends GutHookScript

# Avant tous les tests : la sauvegarde va dans un fichier a part, efface au depart,
# pour ne jamais lire ni ecrire la vraie progression du joueur.

const TEST_SAVE_PATH := "user://test_save.cfg"


func run() -> void:
	SaveData.path = TEST_SAVE_PATH
	SaveData.erase()
