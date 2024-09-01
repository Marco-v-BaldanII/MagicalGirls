extends Option

const ONLINE_MENU = preload("res://Scenes/menu_scenes/Online_Menu.tscn")

func execute_option():
	GameManager.character_selection_mode = 0
	SceneWrapper.change_scene(ONLINE_MENU)
	return true
