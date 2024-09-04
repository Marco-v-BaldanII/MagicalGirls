extends Control

@onready var cursor: Sprite2D = $cursor

func _on_texture_button_toggled(toggled_on):
	
	if toggled_on == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_texture_button_2_toggled(toggled_on):
	SceneWrapper.change_scene(load("res://Scenes/menu_scenes/ReMapControls.tscn"))
	pass 

@export var options : Array[Control]
var index := 0
var timer := 0.15

func _ready() -> void:
	cursor.global_position = options[index % options.size()].global_position

var current_slider : HSlider = null

func _process(delta: float) -> void:
	
	timer -= delta
	
	if timer <= 0:
		
		if Controls.is_ui_action_pressed("move_up"):
			index -= 1
			timer = 0.15
			cursor.global_position = options[index % options.size()].global_position
			if current_slider != null: current_slider.deselect()
		if Controls.is_ui_action_pressed("move_down"):
			index += 1
			timer = 0.15
			cursor.global_position = options[index % options.size()].global_position
			if current_slider != null: current_slider.deselect()
			
	if Controls.is_joy_button_just_pressed("accept"):
		if options[index % options.size()] is TextureButton:
			var btn := options[index % options.size()] as TextureButton
			btn.toggled.emit(! btn.button_pressed)
			btn.button_pressed = ! btn.button_pressed
			current_slider = null
		else:
			current_slider = options[index % options.size()]
			current_slider.execute_option()
			pass
	if Controls.is_joy_button_just_pressed("go_back"):
		
		_on_go_back_button_down()


func _on_go_back_button_down() -> void:
	SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))
	pass # Replace with function body.
