extends Node2D
class_name MyLobby

@onready var go_back: Button = $"../goBack/go_back"
@onready var label: Label = $Label


func _input(event: InputEvent) -> void:

	if visible and Input.is_joy_button_pressed(0,Controls.ui["go_back"][0]) or Input.is_physical_key_pressed(Controls.ui["go_back"][1]):
		go_back.pressed.emit()

func _on_go_back_pressed() -> void:
	if visible:
		hide()
		GDSync.leave_lobby()
		$"../LobbyCreator".show()
