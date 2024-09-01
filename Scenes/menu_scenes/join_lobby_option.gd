extends Option
class_name JoinLobbyOption

@onready var label: Label = $Label


func execite_option() -> bool:
	
	GDSync.join_lobby(label.text, "Password123")
	
	return true
