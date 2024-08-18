extends State
class_name AirMoveState

var player : Player

var j_x : float
var j_y : float

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	player.grounded = false
	player.velocity.x = 0
	
	j_x = player.joy_x
	j_y = player.joy_y


var air_buffer 

func physics_update(delta : float):

	var joy_x = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X)
	var joy_y = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_Y)
	
	if player.fly and not player.is_on_floor():
		#print("so when jumping j_x is" + str(j_x))
		if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_right"]) or joy_x > 0.1:
			player.input_direction = 1

		elif Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_left"]) or joy_x < -0.1:
			player.input_direction =  -1
			
		player.velocity.x = player.FLY_SPEED * player.input_direction
	
	if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0:
		player.jump_lag = 100
		if not player.fly:
			player.velocity.y = player.JUMP_VELOCITY
		else:
			player.velocity.y = player.JUMP_VELOCITY*0.4
		print("while jumping axis is "+ str(joy_x))
		if player.input_buffer.has("move_left") or j_x < -0.1:
				player.velocity.x = -player.air_speed
		elif player.input_buffer.has("move_right") or j_x > 0.1:
				player.velocity.x = player.air_speed
	
	#LAND	
	elif player.is_on_floor() and not player.grounded:
		player.animation_tree["parameters/conditions/land"] = true
		player.grounded = true
		player.jump_lag = 0.01666 * player.JUMP_LAG_FPS
		await get_tree().create_timer(0.017 * 6).timeout
		player.animation_tree["parameters/conditions/land"] = false
		
		Transitioned.emit(self, "ground_move")
	print(joy_y)
	# Add the gravity.
	if not player.is_on_floor() :
		if player.fly and not Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["crouch"]) and not joy_y > 0.7:
			print("fall")
			if player.velocity.y < 0:
				player.velocity.y += (player.gravity*0.2) * delta
			else:
				player.velocity.y += (player.gravity/5) * delta
		else:
			player.velocity.y += (player.gravity) * delta
