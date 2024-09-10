extends GridContainer
class_name LobbyMenu
@onready var p1_control_selection: ScrollMenu = $"../"

const LOBBY_OPTION = preload("res://Scenes/menu_scenes/options/lobby_option.tscn")

var _lobbies : Dictionary = {
	
	"bcfgkdbhri7ghdrbgyu" : true
}

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
		if not _lobbies.has(lobby["Name"]):
			var option = LOBBY_OPTION.instantiate() as JoinLobbyOption
			add_child(option)
			
			_lobbies[lobby["Name"]] = true
			option.label.text = lobby["Name"]
			option.password_edit = $"../../password_edit"    
			p1_control_selection.options.push_back(option)
			p1_control_selection._change_cursor_pos()
			
			if lobby["Tags"]["public"] == false:
				option.show_lock(true)
		
	pass
