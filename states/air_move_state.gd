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
	else:
		player.animation_tree["parameters/conditions/not_crouch"] = true
		player.animation_tree["parameters/conditions/crouch"] = false
		player.animation_tree["parameters/conditions/land"] = false
	player.grounded = false
	player.velocity.x = 0
	
	j_x = player.joy_x
	j_y = player.joy_y


var air_buffer 

func physics_update(delta : float):
	
	var joy_x := .0; var joy_y := .0;
	
	if player.input_method != 2 :#Not using keyboard
		joy_x = Input.get_joy_axis(player.input_method, JOY_AXIS_LEFT_X)
		joy_y = Input.get_joy_axis(player.input_method, JOY_AXIS_LEFT_Y)
	
	if  player.can_move : 
		if player.fly and not player.is_on_floor() and player.can_move and not player.lag and not player.ai_player:
			
			if player.is_mapped_action_pressed("move_right") or joy_x > 0.1 :
				if player.velocity.x < 0:player.velocity.x *= -0.5
				player.input_direction = 1

			elif player.is_mapped_action_pressed("move_left") or joy_x < -0.1 :
				if player.velocity.x > 0:player.velocity.x *= -0.5
				player.input_direction =  -1
				
			player.velocity.x += (player.FLY_SPEED * player.input_direction)/100
			
		elif player.fly and not player.is_on_floor() and player.can_move and not player.lag and  player.ai_player:
			if player.is_input_pressed("move_right"):
				if player.velocity.x < 0:player.velocity.x *= -0.5
				player.input_direction = 1

			elif player.is_input_pressed("move_left"):
				if player.velocity.x > 0:player.velocity.x *= -0.5
				player.input_direction =  -1

			player.velocity.x += (player.FLY_SPEED * player.input_direction)/100

		
		if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0 and not player.lag:
			player.jump_lag = 100
			jump_anim()
			GDSync.call_func(jump_anim)
			
			
			
			if not player.fly:
				player.velocity.y = player.JUMP_VELOCITY
			else:
				player.velocity.y = player.JUMP_VELOCITY*0.47

			if player.is_mapped_action_pressed("move_left") or  j_x < -0.1 or player.is_input_pressed("move_left") :
					player.velocity.x += -player.air_speed
			elif player.is_mapped_action_pressed("move_right") or j_x > 0.1 or player.is_input_pressed("move_right") :
					player.velocity.x += player.air_speed
			player.clear_buffer()
		
		#LAND	
		elif player.is_on_floor() and not player.grounded:
			land_anim()
			GDSync.call_func(land_anim)
			player.grounded = true
			player.jump_lag = 0.01666 * player.JUMP_LAG_FPS
			print("rest_jump_lag")
			Transitioned.emit(self, "ground_move")

	# Add the gravity.
	if not player.is_on_floor() :
		if player.fly and not player.is_mapped_action_pressed("crouch") and not joy_y > 0.7:

			if player.velocity.y < 0:
				player.velocity.y += (player.gravity*0.2) * delta
			else:
				player.velocity.y += (player.gravity/5) * delta
		
		else:
			player.velocity.y += (player.gravity) * delta


func jump_anim():
	player.animation_tree["parameters/conditions/jump"] = true
	
func land_anim():
	player.animation_tree["parameters/conditions/land"] = true
	player.animation_tree["parameters/conditions/jump"] = false
