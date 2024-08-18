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


func hit_stop_short():
	Engine.time_scale = 0
	await get_tree().create_timer(0.08,true,false,true).timeout
	Engine.time_scale = 1

func hit_stop_long():
	Engine.time_scale = 0
	await get_tree().create_timer(0.16,true,false,true).timeout
	Engine.time_scale = 1
