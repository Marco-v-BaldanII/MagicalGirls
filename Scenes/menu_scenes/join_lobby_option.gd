extends Option
class_name JoinLobbyOption

@onready var label: Label = $Label

var password_edit : TextEdit

var _lobbies : Array

func execute_option() -> bool:
	GDSync.lobbies_received.connect(receive_lobbies)
	GDSync.get_public_lobbies()
	

	
	return true

func receive_lobbies(lobbies : Array):
	_lobbies = lobbies
	
	var password : String = "Password123"
	
	for lobby in _lobbies:
		if lobby["Name"] == label.text:
		
			if lobby["Tags"]["public"] == true:
				pass
			else:
				#the lobby is private and you need to input a password
				password = password_edit.text
			break
				

	
	GDSync.join_lobby(label.text, password)
	
	await get_tree().create_timer(0.5).timeout
	
	if GameManager.in_lobby == false:
		$"Error Pannel".show()
		await get_tree().create_timer(2).timeout
		$"Error Pannel".hide()
	
	pass

func show_lock(show : bool):
	if show : $lock.show()
