extends GridContainer
class_name LobbyMenu

const LOBBY_OPTION = preload("res://Scenes/menu_scenes/options/lobby_option.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.lobbies_received.connect(receive_lobbies)
	
	GDSync.get_public_lobbies()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func receive_lobbies(lobbies : Array):
	for lobby in lobbies:
		var option = LOBBY_OPTION.instantiate()
		add_child(option)
		option.label.text = lobby["Name"]
		
	pass
