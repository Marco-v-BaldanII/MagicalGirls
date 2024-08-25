extends Control

func _ready() -> void:
	DialogueManager.show_example_dialogue_balloon(load("res://Dialogues/test.dialogue"), "start")
