extends State
class_name Approach_State

var player : Player

@export var atk_distance : int = 380

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
	Transitioned.emit(self, "camp")
	if player.crouching : return
	player.animation_tree["parameters/conditions/crouch"] = false
	player.animation_tree["parameters/conditions/not_crouch"] = true
	player.can_move = true
	
	if abs(player.oponent.global_position.x - player.global_position.x) > atk_distance:
		if player.oponent.direction == "left":
			player.ai_press_input("move_left",2)
			player.input_buffer.push_back("move_left")
		else:
			player.ai_press_input("move_right",2)
			player.input_buffer.push_back("move_right")
	else:
		Transitioned.emit(self, "attack")
		pass
	pass
