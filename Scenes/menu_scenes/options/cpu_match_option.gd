extends Option

const CHARACTER_SELECTION_SCREEN = preload("res://Scenes/menu_scenes/CharacterSelectionScreen.tscn")

func execute_option():
	GameManager.character_selection_mode = 2
	SceneWrapper.change_scene(CHARACTER_SELECTION_SCREEN)
	return true
