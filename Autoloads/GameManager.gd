extends Node


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
var default_camera_pos : Vector2

func hit_stop_short():
	Engine.time_scale = 0
	await get_tree().create_timer(0.08,true,false,true).timeout
	Engine.time_scale = 1

func hit_stop_long():
	Engine.time_scale = 0
	await get_tree().create_timer(0.16,true,false,true).timeout
	Engine.time_scale = 1

func camera_shake():
	default_camera_pos = camera.position
	var frames = 6
	while frames > 0:
		frames -= 1
		shaking_cam()
		await get_tree().create_timer(0.01667).timeout
	while camera.position != default_camera_pos:
		print("Tweeeeening")
		camera.position = camera.position.move_toward(default_camera_pos, 0.1)
		
var cam_offset = 0

func shaking_cam():
	cam_offset = Vector2(randf_range(-1,1) * shake_amount, randf_range(-1,1)*shake_amount)
	camera.position += cam_offset
	print(camera.position)
