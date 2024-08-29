extends Node

func _ready() -> void:
	GDSync.expose_node(self)

signal joined_lobby
signal online_setup

var is_host : bool = false

@onready var p1 : PackedScene = preload("res://Scenes/Entities/Larissa.tscn")
@onready var p2 : PackedScene = preload("res://Scenes/Entities/Ellie Quinn.tscn")

var p1_spawns : Node2D
var p2_spawns : Node2D

signal initialized_players(p1 : Player , p2 : Player)


var online : bool:
	set(value):
		online = value
		if value == true:
			for i in players.size():
				players[i].set_hitboxes(i)
				players[i].player_id = 0
		else:
			for i in players.size():
				players[i].player_id = i

var players : Array[Player]
var camera : Camera2D
var shake_amount : float = 8
var default_camera_pos : Vector2 = Vector2(0,0)

var character_selection_mode : int = 0
#0 = LOCAL_2P , 1 = ONLINE_2P , 2 = CPU

	

func add_player(player : Player):
	players.push_back(player)
	player.player_num = players.size()

func hit_stop_short():
	#GDSync.call_func(hit_stop_short)
	Engine.time_scale = 0
	await get_tree().create_timer(0.08,true,false,true).timeout
	Engine.time_scale = 1

func hit_stop_long():
	#GDSync.call_func(hit_stop_long)
	Engine.time_scale = 0
	await get_tree().create_timer(0.16,true,false,true).timeout
	Engine.time_scale = 1

func camera_shake():
	#GDSync.call_func(camera_shake)
	if camera != null:
		if default_camera_pos == Vector2.ZERO : default_camera_pos = camera.position
		var frames = 6
		while frames > 0:
			frames -= 1
			shaking_cam()
			await get_tree().create_timer(0.01667).timeout
		while camera.position != default_camera_pos:
			
			camera.position = camera.position.move_toward(default_camera_pos, 2)
		
var cam_offset = 0

func shaking_cam():
	cam_offset = Vector2(randf_range(-1,1) * shake_amount, randf_range(-1,1)*shake_amount)
	camera.position += cam_offset
	print(camera.position)
