extends Player
class_name Ritsu

var current_start_projectile : Projectile
const STAR_RIGHT = preload("res://Scenes/projectiles/star_right.tscn")
const STAR_DIAGONAL = preload("res://Scenes/projectiles/star_diagonal.tscn")

@export var star_cost : int = 10

const SLIDE_KICK_SPEED : int = 1400

func _ready() -> void:

	super()
	await fully_instanciated
	
	if player_num == 1:
		$PositionSynchronizer.broadcast = 0
	else: $PositionSynchronizer.broadcast = 1
		

func instanciate_star():
	current_start_projectile = STAR_RIGHT.instantiate()
	current_start_projectile.online_synch(player_num)
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
					
					if  enough_mp(moveset[specials + "_cost"]) : #if you have enough mp
						
						if specials.contains("ulti"):
							sprite_2d.modulate = Color(0,0.39,0.95,1)
							match_setting.inverted_effect(global_position, direction)
							
							var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

							GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
							instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn",specials)
							
							clear_buffer()
							await get_tree().create_timer(0.4).timeout
							sprite_2d.modulate = Color.WHITE
							await lag_finished
							
							add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
							
							#await get_tree().create_timer(0.1).timeout
							
							return
						
						
						var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

						GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
						instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn",specials)
						
						clear_buffer()
						
						await lag_finished
						
						add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
						#Here will call the animation in the animation tree , which will have it's hitstun
					
						return
	
	
	
	if (input_buffer.back().contains("punch") or input_buffer.back().contains("kick"))and not  input_buffer.back().contains("s_punch"):
		if sfx.has(input_buffer.back()) and not sfx[input_buffer.back()] is bool:
			
				audio_stream.stream = sfx[input_buffer.back()]
				audio_stream.play()
		velocity.x = 0
		
		
		var move : String = input_buffer.back()
		if is_on_floor() and not crouching:
			last_used_move =  move
			can_move = false #Can't move while ground attacks
			$AnimationTree["parameters/conditions/" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + move] = false
			animation_player.play(move)
			clear_buffer()
			GDSync.call_func(_sync_move,[move])
		elif crouching:
			last_used_move = "crouch_" + move
			animation_player.play(last_used_move)
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = false
			
			if last_used_move == "crouch_s_kick":
				if direction == "left": velocity.x = SLIDE_KICK_SPEED
				else: velocity.x = -SLIDE_KICK_SPEED
				await get_tree().create_timer(0.0167 * 10).timeout
				velocity.x = 0
			
			clear_buffer()
			GDSync.call_func(_sync_move,["crouch_" + move])
		else:
			last_used_move = "air_" + move
			animation_player.play(last_used_move)
			$AnimationTree["parameters/conditions/" + "air_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "air_" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,["air_" + move])
			
		GDSync.call_func(store_last_used_move,[last_used_move])
		
	elif input_buffer.back().contains("s_punch") and current_start_projectile == null and  is_on_floor():
		
		if enough_mp(50):
			var move : String = "s_punch"
			if crouching: move = "crouch_s_punch"
			$AnimationTree["parameters/conditions/not_" + move] = false
			$AnimationTree["parameters/conditions/" + move] = true
			
			GDSync.call_func(_sync_move,[move])
			
			var star = instanciate_star()
			GDSync.set_gdsync_owner(star,GDSync.get_client_id())
			GDSync.call_func(instanciate_star)
			while is_mapped_action_pressed("s_punch"):
				await get_tree().create_timer(0.0167).timeout
			$AnimationTree["parameters/conditions/not_" + move] = true
			$AnimationTree["parameters/conditions/" + move] = false

		
	#diagonal non chargeable projectile on  air
	elif not is_on_floor() and input_buffer.back().contains("s_punch") and not current_start_projectile:
		if  enough_mp(star_cost):
			instanciate_diagonal_star()
			GDSync.call_func(instanciate_diagonal_star)
			clear_buffer()
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
	if input_buffer.size() > 0 and input_buffer.back().contains("jump") and is_on_floor() and not crouching and jump_lag <= 0:
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
		if current_start_projectile != null and (is_mapped_action_pressed("s_punch") or is_input_pressed("s_punch")) and enough_mp(1):
			current_start_projectile.charge(global_position)
			charging_mp = false
			
			var move : String = "s_punch"
			if crouching: move = "crouch_s_punch"
			
			$AnimationTree["parameters/conditions/" + move] = true
			GDSync.call_func(_sync_move,[move])
			pass
		elif current_start_projectile != null:
			charging_mp = true
			
			var move : String = "s_punch"
			if crouching: move = "crouch_s_punch"
			
			$AnimationTree["parameters/conditions/" + move] = false
			GDSync.call_func(_sync_move,["not_"+ move])
			_sync_move("not_"+ move)
			if oponent : current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
			else : current_start_projectile.shoot((player_num-1) + 2, 0 ,direction, self)
			velocity.x = 0
			
			if crouching: 
				current_start_projectile.position.y += 82
		
			current_start_projectile = null

	#if input_buffer.size() > 0:
	#if input_buffer.back().contains("jump") and is_on_floor() and not crouching and jump_lag <= 0:
		##Force the player to throw the projectile when jumping
		#if current_start_projectile != null:
			#current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
			#current_start_projectile = null
			#
		#joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
#
		#state_machine.on_child_transition(state_machine.current_state, "air_move")


func _on_body_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_head_hurt_box_area_entered(area: Area2D) -> void:
	
	if crouching:
		head = true
		_on_hurt_box_area_entered(area)

		head = false

	pass # Replace with function body.

func set_hitboxes(player_id : int):
	if player_num == 1:
		$hit_boxes/special_box.set_collision_layer_value(2, true)
		hit_box_1.set_collision_layer_value(2, true)
		hit_box_2.set_collision_layer_value(2, true)
		hurt_box.set_collision_mask_value(3, true)
		hurt_box.set_collision_layer_value(4,true)
		head_hurt_box.set_collision_mask_value(3,true)
		hurt_box_layer = 4

	else:
		$hit_boxes/special_box.set_collision_layer_value(3, true)
		hit_box_1.set_collision_layer_value(3, true)
		hit_box_2.set_collision_layer_value(3, true)
		hurt_box.set_collision_mask_value(2, true)
		hurt_box.set_collision_layer_value(5,true)
		head_hurt_box.set_collision_mask_value(2,true)
		hurt_box_layer = 5
