extends State
class_name CrouchState

var player : Player

func enter():
	GDSync.expose_node(self)
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e

	player.velocity.x = 0
	player.animation_tree["parameters/conditions/crouch"] = true
	player.crouching = true


func physics_update(delta : float):
	
	var joy_x = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X)
	var joy_y = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_Y)

	if (not Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["crouch"]) and 
	not(joy_y ==  1 and abs(joy_x) < 0.4)) and GDSync.is_gdsync_owner(player):
		
		transition_ground()
		GDSync.call_func(transition_ground)
	
	

func exit():
	player.crouching = false

func transition_ground():
	Transitioned.emit(self, "ground_move")
	player.animation_tree["parameters/conditions/crouch"] = false
	player.animation_tree["parameters/conditions/not_crouch"] = true
	player.animation_tree["parameters/conditions/not_crouch"] = false
