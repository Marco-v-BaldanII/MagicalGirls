extends State
class_name GroundMoveState

var player : Player

func enter():

	GDSync.expose_node(self)
	crouching = false
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	else:
		player.animation_tree["parameters/conditions/idle_anim"] = true
		player.animation_tree["parameters/conditions/move_forward"] = false
		player.animation_tree["parameters/conditions/move_backward"] = false
		player.animation_tree["parameters/conditions/jump"] = false
		player.animation_tree["parameters/conditions/land"] = true
		player.animation_tree.set("parameters/playback/current", "idle_anim")
		return



var crouching : bool = false

func physics_update(delta : float):
	if  player.lag: 
		return
	if not player.ai_player:
		#Not ai player
		if  player.is_mapped_action_pressed("move_right") or Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X) == 1:
			player.input_direction = 1

		elif  player.is_mapped_action_pressed("move_left") or Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X) == -1:
			player.input_direction =  -1
			
		else:

			if player.animation_tree["parameters/conditions/idle_anim"] == false:
				idle_anim()
				GDSync.call_func(idle_anim)
				
			player.input_direction -= 0.2
			player.input_direction = clamp(player.input_direction, 0,1)
			#play idle
			
	else:
		#AI player
		if (player.input_buffer.size() > 0 and player.input_buffer.back() == "move_right" and player.ai_player) :
			player.input_direction = 1
		elif (player.input_buffer.size() > 0 and player.input_buffer.back() == "move_left" and player.ai_player) :
			player.input_direction = -1
		
		
		else:
			player.input_direction -= 0.2
			player.input_direction = clamp(player.input_direction, 0,1)
			if player.animation_tree["parameters/conditions/idle_anim"] == false:
				idle_anim()
				GDSync.call_func(idle_anim)

	if player.is_on_floor() and player.can_move: #Can move is turned on by the animation finished method
		player.jump_lag -= delta
		player.moving_backwards = false
		if(player.input_direction > 0 and player.direction == "left") or (player.input_direction < 0 and player.direction == "right"):
			
			player.velocity.x = player.input_direction * player.SPEED
			if player.animation_tree["parameters/conditions/move_forward"] == false: 

				move_froward_anim()
				GDSync.call_func(move_froward_anim)
			#player.animation_tree["parameters/conditions/ilde_anim"] = false
			
		else:
			#move slower in your back direction
			player.velocity.x = player.input_direction * (player.SPEED*0.55)
			if player.input_direction != 0 and  player.animation_tree["parameters/conditions/move_backward"] == false: 

				move_backward_anim()
				GDSync.call_func(move_backward_anim)
				
			if player.input_direction != 0 :player.moving_backwards = true
			
	elif player.is_on_floor():
		player.jump_lag -= delta
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	else:
		player.grounded = false
		player.animation_tree["parameters/conditions/land"] = false
		Transitioned.emit(self, "air_move")


	var joy_x := .0; var joy_y := .0;
	if player.input_method != 2: #Not using keyboard
		joy_x = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X)
		joy_y = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_Y)

	#Transition to crouch
	var v = player.velocity
	
	if (player.can_move and player.is_mapped_action_pressed("crouch")) or ((joy_y ==  1 and abs(joy_x) < 0.4) and crouching == false and player.can_move) :
			if not player.ai_player:
			
				if not GameManager.online or (GameManager.online and GDSync.is_gdsync_owner(player)):
					Transitioned.emit(self, "crouch")
					crouching = true
					
				if GameManager.online and GDSync.is_gdsync_owner(player):
					GDSync.call_func(transition_to_crouch)
					
	if (player.ai_player and player.can_move and player.is_input_pressed("crouch")):
		Transitioned.emit(self, "crouch")	


func update(delta : float):
	pass


func transition_to_crouch():
	Transitioned.emit(self, "crouch")
	crouching = true


func move_froward_anim():
	player.animation_tree["parameters/conditions/move_backward"] = false
	player.animation_tree["parameters/conditions/move_forward"] = true
	player.animation_tree["parameters/conditions/idle_anim"] = false
	
func idle_anim():
	player.animation_tree["parameters/conditions/land"] = false
	player.animation_tree["parameters/conditions/idle_anim"] = true
	player.animation_tree["parameters/conditions/move_forward"] = false
	player.animation_tree["parameters/conditions/move_backward"] = false
	
func move_backward_anim():
	player.animation_tree["parameters/conditions/move_backward"] = true
	player.animation_tree["parameters/conditions/move_forward"] = false
	player.animation_tree["parameters/conditions/idle_anim"] = false
