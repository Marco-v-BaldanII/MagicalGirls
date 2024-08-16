extends State
class_name AirMoveState

var player : Player

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	player.grounded = false
	player.velocity.x = 0


func physics_update(delta : float):
	
	
	if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0:
		player.jump_lag = 100
		player.velocity.y = player.JUMP_VELOCITY
		if player.input_buffer.has("move_left"):
				player.velocity.x = -player.air_speed
		elif player.input_buffer.has("move_right"):
				player.velocity.x = player.air_speed
				
		print(player.velocity.x)
	
	#LAND	
	elif player.is_on_floor() and not player.grounded:
		player.animation_tree["parameters/conditions/land"] = true
		player.grounded = true
		player.jump_lag = 0.01666 * player.JUMP_LAG_FPS
		await get_tree().create_timer(0.017 * 6).timeout
		player.animation_tree["parameters/conditions/land"] = false
		
		Transitioned.emit(self, "ground_move")
	
	# Add the gravity.
	if not player.is_on_floor() :
		player.velocity.y += player.gravity * delta
