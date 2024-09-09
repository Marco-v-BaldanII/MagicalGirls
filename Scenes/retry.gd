extends Node2D

@onready var time_label: Label = $time_label
var time : float = 9.0:
	set(value):
		time = clamp(value,0,9)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	time -= delta
	time_label.text = str(floori(time))
	
	if time <= 0:
		SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))
	
	if Controls.is_ui_action_pressed("start"):
		GameManager.load_arcade_battle()
		pass
	
	pass
