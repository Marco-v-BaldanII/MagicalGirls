extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
		await get_tree().create_timer(0.8).timeout	
		DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/test.dialogue"), "start")
