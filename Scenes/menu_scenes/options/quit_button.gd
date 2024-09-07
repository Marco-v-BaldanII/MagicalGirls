extends Option


func execute_option() -> bool:
	$"../../..".deactivate()
	SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))
	
	return true
