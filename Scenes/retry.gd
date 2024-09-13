extends Node2D

@onready var time_label: Label = $time_label
var time : float = 9.0:
	set(value):
		time = clamp(value,0,9)
@onready var label: Label = $Label3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var winner : String = GameManager.winner_name;
	var looser : String = GameManager.looser_name;
	
	$portrait.texture = load( "res://Assets/portraits/" + winner)
	
	if winner == "Ritsu" and looser == "Ellie Quinn":
		label.text = "Looks like you didn't study enough for this fight !"
	elif winner == "Ritsu" and looser == "Anastasia":
		label.text = " You should have chosen Mahou 0,0% for this occasion"
	elif winner == "Ritsu" and looser == "Ritsu":
		label.text = "You will now traverse my sea of grief and blood"
		
	elif winner == "Anastasia" and looser == "Ellie Quinn":
		label.text = "Drunk ones +1, goofy nerds -1"
		
	elif winner == "Anastasia" and looser == "Ritsu":
		label.text = "HQ, HQ, objective annihilated"
		
	elif winner == "Anastasia" and looser == "Anastasia":
		label.text = "Has the memory gone? Are you feeling numb?"
		
		
	elif winner == "Ellie Quinn" and looser == "Ellie Quinn":
		pass	
	elif winner == "Ellie Quinn" and looser == "Ritsu":
		label .text = "It seems that you forgot to read my book “Magical girl combat 101”"
		
	elif winner == "Ellie Quinn" and looser == "Anastasia":
		label.text = "Vodka… It gives you no tactical advantage, whatsoever"
	
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
