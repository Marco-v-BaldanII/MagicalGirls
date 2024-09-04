extends Control

func _on_texture_button_toggled(toggled_on):
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_texture_button_2_toggled(toggled_on):
	SceneWrapper.change_scene(load("res://Scenes/menu_scenes/ReMapControls.tscn"))
	pass 
