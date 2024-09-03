extends Player
class_name Ritsu

var current_start_projectile : Projectile
const STAR_RIGHT = preload("res://Scenes/projectiles/star_right.tscn")
const STAR_DIAGONAL = preload("res://Scenes/projectiles/star_diagonal.tscn")

func _input(event):
	if not can_move: return
	
	if not GameManager.online or GDSync.is_gdsync_owner(self):
		if input_method != 3: #not using keyboard
			joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
			joy_y = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_Y)
		
		if is_joy_button_just_pressed("move_left") or (joy_x == -1 and abs(joy_y) < 0.4):
			add_input_to_buffer("move_left")
			perform_move()
		if is_joy_button_just_pressed("move_right") or (joy_x == 1 and abs(joy_y) <0.4):
			add_input_to_buffer("move_right")
			perform_move()
		if is_joy_button_just_pressed("crouch") or (joy_y ==  1 and abs(joy_x) < 0.4):
			add_input_to_buffer("crouch")
			perform_move()
		if is_joy_button_just_pressed("jump") or (joy_y < -0.2 and abs(joy_x) < 0.4 ):
			#print("jump with a y of " + str(joy_y) +"and a x of " + str(joy_x))
			add_input_to_buffer("jump")
			perform_move()
		if is_joy_button_just_pressed("s_punch"):
			add_input_to_buffer("s_punch")
			perform_move()
		if is_joy_button_just_pressed("w_punch"):
			add_input_to_buffer("w_punch")
			perform_move()
		if is_joy_button_just_pressed("s_kick"):
			add_input_to_buffer("s_kick")
			perform_move()
		if is_joy_button_just_pressed("w_kick"):
			add_input_to_buffer("w_kick")
			perform_move()
		
func instanciate_star():
	current_start_projectile = STAR_RIGHT.instantiate()
	get_tree().root.add_child(current_start_projectile)
	return current_start_projectile
	
	
func instanciate_diagonal_star():
	current_start_projectile = STAR_DIAGONAL.instantiate()
	get_tree().root.add_child(current_start_projectile)
	current_start_projectile.speedY = 400
	current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	
	current_start_projectile.global_position = global_position
	
	current_start_projectile = null
	
func perform_move():
	if not can_move and not lag: return
	
	#$AnimationTree["parameters/conditions/idle_anim"] = true
	#animation_tree.set("parameters/playback/current", "idle_anim")
	#await get_tree().create_timer(0.01667).timeout
	
	for specials in moveset:
		if  moveset[specials] is Array[String] and moveset[specials].size() <= input_buffer.size()  and  has_subarray(moveset[specials], input_buffer):
			var dir = find_special_direction(specials)
			if dir != direction:
				print(specials + dir)
				
				if FileAccess.file_exists("res://Scenes/projectiles/"+specials+".tscn"):
					var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

					GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
					instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn",specials)
					
					clear_buffer()
					
					await lag_finished
					
					add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
					#Here will call the animation in the animation tree , which will have it's hitstun

					return
			
	if (input_buffer.back().contains("punch") or input_buffer.back().contains("kick"))and not  input_buffer.back().contains("s_punch"):
		
		velocity.x = 0
		
		var move : String = input_buffer.back()
		if is_on_floor() and not crouching:
			last_used_move =  move
			can_move = false #Can't move while ground attacks
			$AnimationTree["parameters/conditions/" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,[move])
		elif crouching:
			last_used_move = "crouch_" + move

			$AnimationTree["parameters/conditions/" + "crouch_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = false
			
			clear_buffer()
			GDSync.call_func(_sync_move,["crouch_" + move])
		else:
			last_used_move = "air_" + move
			$AnimationTree["parameters/conditions/" + "air_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "air_" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,["air_" + move])
			
		GDSync.call_func(store_last_used_move,[last_used_move])
		
	elif input_buffer.back().contains("s_punch") and current_start_projectile == null and  is_on_floor():

		var star = instanciate_star()
		GDSync.set_gdsync_owner(star,GDSync.get_client_id())
		GDSync.call_func(instanciate_star)

		
	#diagonal non chargeable projectile on  air
	elif not is_on_floor() and input_buffer.back().contains("s_punch") and not current_start_projectile:
		
		instanciate_diagonal_star()
		GDSync.call_func(instanciate_diagonal_star)
		
		var i = 0
		can_move = false
		if direction == "left":
			while i < 8:
				#velocity.x = FLY_SPEED * -0.4
				i += 1
				can_move = false
				await get_tree().create_timer(0.01667).timeout
		else:
			while i < 8:
				#velocity.x = FLY_SPEED * 0.4
				i += 1
				can_move = false
				await get_tree().create_timer(0.01667).timeout
		can_move = true
		#input_direction = 0
		
	elif input_buffer.back().contains("jump") and is_on_floor() and not crouching:
		#Force the player to throw the projectile when jumping
		if current_start_projectile != null:
			current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
			current_start_projectile = null
			
		joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)

		state_machine.on_child_transition(state_machine.current_state, "air_move")


func _physics_process(delta: float) -> void:
	if not GDSync.is_gdsync_owner(self): return

	super._physics_process(delta)
	
	if is_on_floor():
		if current_start_projectile != null and (is_mapped_action_pressed("s_punch") or is_input_pressed("s_punch")):
			current_start_projectile.charge(global_position)
			pass
		elif current_start_projectile != null:
			if oponent : current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
			else : current_start_projectile.shoot((player_num-1) + 2, 0 ,direction, self)
			velocity.x = 0
			
			if crouching: 
				current_start_projectile.position.y += 82
		
			current_start_projectile = null
			


func _on_body_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
