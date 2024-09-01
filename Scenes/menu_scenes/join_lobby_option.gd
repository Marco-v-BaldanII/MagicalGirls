extends Option
class_name JoinLobbyOption

@onready var label: Label = $Label
var _lobbies : Array

func execute_option() -> bool:
	GDSync.lobbies_received.connect(receive_lobbies)
	GDSync.get_public_lobbies()
	
	for lobby in _lobbies:
		
		if lobby.tags["public"] == true:
			return true
		else:
			return false
	
	GDSync.join_lobby(label.text, "Password123")
	
	return true

func receive_lobbies(lobbies : Array):
	_lobbies = lobbies
