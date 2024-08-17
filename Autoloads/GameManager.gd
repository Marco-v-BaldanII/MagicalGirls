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
