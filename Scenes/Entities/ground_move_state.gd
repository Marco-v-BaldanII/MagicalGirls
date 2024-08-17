extends State
class_name GroundMoveState

var player : Player

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	await get_tree().create_timer(0.5).timeout
	#player.animation_tree["parameters/conditions/not_crouch"] = true


func physics_update(delta : float):

	if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_right"]):
		player.input_direction = 1

	elif Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_left"]):
		player.input_direction =  -1
	else:
		player.input_direction -= 0.1
		player.input_direction = clamp(player.input_direction, 0,1)

	if player.is_on_floor():
		player.jump_lag -= delta
		player.moving_backwards = false
		if(player.input_direction >= 0 and player.direction == "left") or (player.input_direction <= 0 and player.direction == "right"):
			player.velocity.x = player.input_direction * player.SPEED
			
		else:
			#move slower in your back direction
			player.velocity.x = player.input_direction * (player.SPEED*0.55)
			player.moving_backwards = true
	
	elif player.is_on_floor():
		player.jump_lag -= delta
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	else:
		player.grounded = false
		Transitioned.emit(self, "air_move")

	#Transition to jump
	if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0:
		Transitioned.emit(self, "air_move")
		


	#Transition to crouch
	if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["crouch"]):
		Transitioned.emit(self, "crouch")
