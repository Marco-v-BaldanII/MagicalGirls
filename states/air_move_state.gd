extends State
class_name AirMoveState

var player : Player

var j_x : float
var j_y : float

func _ready() -> void:
	await get_tree().create_timer(0.17).timeout
	if not player:
		
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	GDSync.expose_node(self)
	

func enter():
	floaty = false
	jump_press = 0
	
	if not player:
		
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	else:
		player.play_sfx("jump")
		player.animation_tree["parameters/conditions/not_crouch"] = true
		player.animation_tree["parameters/conditions/crouch"] = false
		player.animation_tree["parameters/conditions/land"] = false
	player.grounded = false
	player.velocity.x = 0
	
	j_x = player.joy_x
	j_y = player.joy_y


var air_buffer 


var floaty : bool = false

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
			player.jump_lag = 9
			jump_anim()
			GDSync.expose_func(jump_anim)
			GDSync.call_func(jump_anim)
			
			
			
			if not floaty:
				player.velocity.y = player.JUMP_VELOCITY
			else:
				player.velocity.y = player.JUMP_VELOCITY *0.47

			if player.is_mapped_action_pressed("move_left") or  j_x < -0.1 or player.is_input_pressed("move_left") :
					player.velocity.x += -player.air_speed
			elif player.is_mapped_action_pressed("move_right") or j_x > 0.1 or player.is_input_pressed("move_right") :
					player.velocity.x += player.air_speed
			player.clear_buffer()
		
		#LAND	
		elif player.is_on_floor() and not player.grounded:
			land_anim()
			GDSync.expose_func(land_anim)
			GDSync.call_func(land_anim)
			
			player.grounded = true
			player.jump_lag = 0.01666 * player.JUMP_LAG_FPS
			print("rest_jump_lag")
			Transitioned.emit(self, "ground_move")
	
	
	
	if is_action_pressed("jump") and player.fly:
		jump_press += 1
		if jump_press >= 2:
			floaty = true
	
	# Add the gravity.
	if not player.is_on_floor() :
		if player.fly and not player.is_mapped_action_pressed("crouch") and not joy_y > 0.7:
			
			
			if is_action_pressed("jump") or (player.input_method != 2 and joy_y < -0.5) :
				
				if player.velocity.y < 0:
					player.velocity.y += (player.gravity) * delta
				else:
					player.velocity.y += (player.gravity/25) * delta
			else:
				player.velocity.y += (player.gravity) * delta
			
		
		else:
			player.velocity.y += (player.gravity) * delta

var jump_press : int = 0

func jump_anim():
	player.animation_tree["parameters/conditions/jump"] = true
	player.animation_tree["parameters/conditions/land"] = false
	
func land_anim():
	player.animation_tree["parameters/conditions/land"] = true
	player.animation_tree["parameters/conditions/jump"] = false



func is_action_pressed(action_name : String) -> bool:
	if player.input_method != 2:
		if action_state[action_name] == false and Input.is_joy_button_pressed( player.input_method, Controls.mapping[player.player_id][action_name][0]) :
			#action_state[action_name] = true
			#listen_for_not_input(action_name)
			return true
		if not Input.is_joy_button_pressed(player.input_method, Controls.mapping[player.input_method][action_name][0]):
			pass
			#action_state[action_name] = false
		return false
	else:
		if action_state[action_name] == false and Input.is_physical_key_pressed(Controls.mapping[player.player_id][action_name][1]) :
			#action_state[action_name] = true
			#listen_for_not_input(action_name)
			return true
		if not Input.is_physical_key_pressed(Controls.mapping[player.player_id][action_name][1]):
			pass
			#action_state[action_name] = false
		return false

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"crouch" : false,
	"jump" : false,
	"w_punch" : false,
	"s_punch" : false,
	"w_kick" : false,
	"s_kick" : false,
	"l_trigger" : false,
	"r_trigger" : false
}
