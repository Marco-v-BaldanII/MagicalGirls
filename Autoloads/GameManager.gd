extends Node

func _ready() -> void:
	GDSync.expose_node(self)
	joined_lobby.connect(online_selection)

signal joined_lobby
signal online_setup

var is_host : bool = false

@onready var p1 : PackedScene = preload( "res://Scenes/Entities/Ritsu.tscn")
@onready var p2 : PackedScene = preload( "res://Scenes/Entities/Ellie Quinn.tscn")

var back_ground : PackedScene

var p1_spawns : Node2D
var p2_spawns : Node2D

signal initialized_players(p1 : Player , p2 : Player)

var in_lobby : bool = false

var online : bool:
	set(value):
		online = value
		if value == true:
			for i in players.size():
				players[i].set_hitboxes(i)
				players[i].player_id = 0
		else:
			for i in players.size():
				if is_instance_valid(players[i]): players[i].player_id = i

var players : Array[Player]
var camera : Camera2D
var shake_amount : float = 8
var default_camera_pos : Vector2 = Vector2(0,0)



var character_selection_mode : int = 0
#0 = LOCAL_2P , 1 = ONLINE_2P , 2 = CPU, 3 = ARCADE, 4 = TRAINING

var arcade_route : ArcadeRun = null
var arcade_index : int = 0

func online_selection():
	character_selection_mode = 1

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
	
func hit_stop_verylong():
	#GDSync.call_func(hit_stop_long)
	get_tree().paused = true
	await get_tree().create_timer(0.3,true,false,true).timeout
	get_tree().paused = false

func camera_shake():
	#GDSync.call_func(camera_shake)
	if camera != null:
		if default_camera_pos == Vector2.ZERO : default_camera_pos = camera.position
		var frames = 6
		while frames > 0:
			frames -= 1
			shaking_cam()
			await get_tree().create_timer(0.01667).timeout
		if not is_instance_valid(camera): return
		while camera.position != default_camera_pos:
			
			camera.position = camera.position.move_toward(default_camera_pos, 2)
		
var cam_offset = 0

func shaking_cam():
	if not is_instance_valid(camera): return
	cam_offset = Vector2(randf_range(-1,1) * shake_amount, randf_range(-1,1)*shake_amount)
	camera.position += cam_offset
	print(camera.position)

var set_points : Array[int] = [0,0]

var winner_name : String = "Ritsu"
var looser_name : String = "Ellie Quinn"

func match_results(winner_id : int):
	if winner_id == -1: #Tie
		SceneWrapper.change_scene(load("res://Scenes/Stages/test_map2_deprecated.tscn"))
		return
		
	winner_id -= 1
	players.clear()
	set_points[winner_id] += 1
	
	if set_points[0] >= 2:
		set_points = [0,0] #reset score
		if character_selection_mode == 0 or character_selection_mode == 2: #Local and cpu
			back_to_character_selection()
		elif character_selection_mode ==  1: #online
			back_to_character_selection(); GDSync.call_func(back_to_character_selection)
		elif character_selection_mode == 3 : #Arcade
			arcade_index += 1
			if FileAccess.file_exists("res://Scenes/Entities/CPU/" + arcade_route.oponents[arcade_index] + "_AI.tscn"):
				
				p2 = load("res://Scenes/Entities/CPU/" + arcade_route.oponents[arcade_index] + "_AI.tscn")
				SceneWrapper.change_scene(load("res://Scenes/Stages/test_map2_deprecated.tscn"))
			pass
		
		pass
	elif set_points[1] >= 2:
		set_points = [0,0] #reset score
		if character_selection_mode == 0 or character_selection_mode == 2:
			back_to_character_selection()
		elif character_selection_mode ==  1:
			back_to_character_selection(); GDSync.call_func(back_to_character_selection)
		elif character_selection_mode == 3 : #Arcade
			SceneWrapper.change_scene(load("res://Scenes/retry.tscn"))
			pass
			#back_to_character_selection()
	else:
		SceneWrapper.change_scene(load("res://Scenes/Stages/test_map2_deprecated.tscn"))

func total_set_matches():
	return set_points[0] + set_points[1]

func back_to_character_selection():

	SceneWrapper.change_scene(load( "res://Scenes/menu_scenes/CharacterSelectionScreen.tscn"))

func load_arcade_battle():
	if FileAccess.file_exists("res://Scenes/Entities/CPU/" + arcade_route.oponents[arcade_index] + "_AI.tscn"):
				
				p2 = load("res://Scenes/Entities/CPU/" + arcade_route.oponents[arcade_index] + "_AI.tscn")
				SceneWrapper.change_scene(load("res://Scenes/Stages/test_map2_deprecated.tscn"))
