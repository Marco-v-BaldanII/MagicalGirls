extends State
class_name Approach_State

var player : AI_Player

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	pass

func exit():
	pass

	
func physics_update(delta : float):

	if abs(player.oponent.global_position.x - player.global_position.x) > player.attack_distance:
		if player.oponent.direction == "left":
			player.press_input("move_left")
			player.input_buffer.push_back("move_left")
		else:
			player.press_input("move_right")
			player.input_buffer.push_back("move_right")
	else:
		Transitioned.emit(self, "attack")
		pass
	pass
