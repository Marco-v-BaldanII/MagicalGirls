extends Node2D
@onready var canvas_layer = $CanvasLayer
@onready var v_box_container: VBoxContainer = $CanvasLayer/VBoxContainer

var online : bool:
	set(value):
		GameManager.online = value
		online = value

var player : PackedScene = preload("res://player.tscn")
@export var player_1: Player 
@export var player_2: Player 


func _ready():
	online = false



func connected():
	print("You are now connected!")
	online = true
	v_box_container.show()


func connection_failed(error : int):
	match(error):
		ENUMS.CONNECTION_FAILED.INVALID_PUBLIC_KEY:
			push_error("The public or private key you entered were invalid.")
		ENUMS.CONNECTION_FAILED.TIMEOUT:
			push_error("Unable to connect, please check your internet connection.")
	  

func lobby_created(lobby_name : String):
	print("Succesfully created lobby "+lobby_name)
	GDSync.join_lobby(lobby_name, "Password123")
#	Now you can join the lobby!

func lobby_creation_failed(lobby_name : String, error : int):
	match(error):
		ENUMS.LOBBY_CREATION_ERROR.LOBBY_ALREADY_EXISTS:
			push_error("A lobby with the name "+lobby_name+" already exists.")
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_SHORT:
			push_error(lobby_name+" is too short.")
		ENUMS.LOBBY_CREATION_ERROR.NAME_TOO_LONG:
			push_error(lobby_name+" is too long.")
		ENUMS.LOBBY_CREATION_ERROR.PASSWORD_TOO_LONG:
			push_error("The password for "+lobby_name+" is too long.")
		ENUMS.LOBBY_CREATION_ERROR.TAGS_TOO_LARGE:
			push_error("The tags have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.DATA_TOO_LARGE:
			push_error("The data have exceeded the 2048 byte limit.")
		ENUMS.LOBBY_CREATION_ERROR.ON_COOLDOWN:
			push_error("Please wait a few seconds before creating another lobby.")
	  

func lobby_joined(lobby_name : String):
	print("Succesfully joined lobby "+lobby_name)
	v_box_container.hide()
	GameManager.joined_lobby.emit()

func lobby_join_failed(lobby_name : String, error : int):
	match(error):
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_DOES_NOT_EXIST:
			push_error("The lobby "+lobby_name+" does not exist.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_CLOSED:
			push_error("The lobby "+lobby_name+" is closed.")
		ENUMS.LOBBY_JOIN_ERROR.LOBBY_IS_FULL:
			push_error("The lobby "+lobby_name+" is full.")
		ENUMS.LOBBY_JOIN_ERROR.INCORRECT_PASSWORD:
			push_error("The password for lobby "+lobby_name+" was incorrect.")
		ENUMS.LOBBY_JOIN_ERROR.DUPLICATE_USERNAME:
			push_error("The lobby "+lobby_name+" already contains your username.")
	  


func _on_host_button_button_down():
	if online:
		GDSync.create_lobby(
		"Lobby Name",
		"Password123",
		true,
		10,
		{
			"Map" : "Desert",
			"Game Mode" : "Free For All"
		}
		)
		GDSync.set_gdsync_owner(player_1, GDSync.get_client_id())
		#i could loop through all it's children and set gdsync owner
	v_box_container.hide()

@onready var node_instantiator := $NodeInstantiator


func _on_join_button_button_down():
	if online:
		GDSync.join_lobby("Lobby Name", "Password123")
		v_box_container.hide()
		#node_instantiator.instantiate_node()


func client_joined(client_id : int):
	if !GDSync.is_host():
		GDSync.set_gdsync_owner(player_2, client_id)


func _on_online_button_button_down() -> void:
	if not online:
	
		GDSync.connected.connect(connected)
		GDSync.connection_failed.connect(connection_failed)
		
		GDSync.start_multiplayer()
		
		GDSync.lobby_created.connect(lobby_created)
		GDSync.lobby_creation_failed.connect(lobby_creation_failed)
		GDSync.lobby_joined.connect(lobby_joined)
		GDSync.lobby_join_failed.connect(lobby_join_failed)
		
		GDSync.client_joined.connect(client_joined)
	else:
		GDSync.close_lobby()
		GDSync.stop_multiplayer()
		online = false
		print("Exited lobby")
		
	
	pass # Replace with function body.
