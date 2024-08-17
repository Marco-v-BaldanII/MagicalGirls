extends Node


var online : bool:
	set(value):
		online = value
		if value == true:
			for i in players.size():
				players[i].set_hitboxes(i)

var players : Array[Player]
