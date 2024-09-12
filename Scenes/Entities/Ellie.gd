extends Player
class_name EllieQuinn

var current_start_projectile : Projectile
const STAR_RIGHT = preload("res://Scenes/projectiles/book_laser.tscn")
const BOOK_FIRE = preload("res://Scenes/projectiles/book_fire.tscn")

const ORBITING_BOOK = preload("res://Scenes/projectiles/orbiting_book.tscn")
const BOOK_PROJECTILE = preload("res://Scenes/projectiles/book_projectile.tscn")


const BOOK_PROJECTILE_STARTUP : int = 14

var fire_cost = 150
var projectile_cost = 26

func _ready() -> void:
	super()
	GDSync.expose_node(self)
	GDSync.expose_func(hello)

func hello():
	pass

func instanciate_projectile_online(path : String, p_name : String, position_offset : Vector2 = Vector2.ZERO, my_self : Player = null):
	var special_scene = load(path)
	var instance = special_scene.instantiate()
	if my_self == null :get_tree().root.add_child(instance)
	else: my_self.add_child(instance)
	instance.global_position = global_position
	
	instance.global_position += position_offset
	
	var startup : int = 0
	if p_name != "": startup = MovesetManager.movesets[character_name][p_name + "_startup"]
	
	if instance.has_method("shoot"):
		if oponent : instance.shoot((player_num-1) + 2, oponent.hurt_box_layer, direction, self,startup)
		else: instance.shoot((player_num-1) + 2, 0 , direction, self, startup)

		
func instanciate_star():
	current_start_projectile = STAR_RIGHT.instantiate()
	get_tree().root.add_child(current_start_projectile)
	charging_laser = true
	return current_start_projectile
	
	
func instanciate_fire(glob_pos : Vector2 = global_position):
	var projectile = BOOK_FIRE.instantiate()
	#current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	projectile.global_position = glob_pos
	#projectile.global_position.y -= 200
	get_tree().root.add_child(projectile)
	
	return projectile
	
func instanciate_book_projectile(glob_pos : Vector2 = global_position):
	var book_proj = BOOK_PROJECTILE.instantiate()
	
	book_proj.global_position = glob_pos
	get_tree().root.add_child(book_proj)
	
	return book_proj
	
	
var charging_laser : bool:
	set(value):
		charging_laser = value
		
		if current_start_projectile is Book_Laser:
			if value == false and current_start_projectile:
				current_start_projectile.deactivate()
			elif value == true and current_start_projectile.fully_charged:
				shoot_laser()


var started_charge : bool = false
	
func perform_move():
	if not can_move and not lag: return
	
	for specials in moveset:
		if  moveset[specials] is Array[String] and moveset[specials].size() <= input_buffer.size()  and  has_subarray(moveset[specials], input_buffer):
			var dir = find_special_direction(specials)
			if dir != direction or dir == "none":
				print(specials + dir)

				if specials == "ellie_ulti" and enough_mp(moveset[specials + "_cost"]):
					
					special_effect_wrapper(global_position, direction)
					if GameManager.online: 
						GDSync.call_func(special_effect_wrapper, [global_position, direction])
					
					clear_buffer()
					
					for key in  move_dmg.keys():
						
						move_dmg[key] *= 2 #double damage on all moves
					
					await get_tree().create_timer(0.5).timeout
					$Sprite2D/GPUParticles_ulti.show()
					await get_tree().create_timer(6.24).timeout
					$Sprite2D/GPUParticles_ulti.hide()
					for key in  move_dmg.keys():
						
						move_dmg[key] /= 2 #return to normal damage
					

					add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
					return
					
				
				else:
					
					if  enough_mp(moveset[specials + "_cost"]) : #if you have enough mp
						var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

						#GDSync.call_func(instanciate_projectile_online,["res://Scenes/projectiles/"+specials+".tscn"])
						instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn", specials)
						
						add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
						#Here will call the animation in the animation tree , which will have it's hitstun
				
			clear_buffer()

			return
			
	if (input_buffer.back().contains("punch") or input_buffer.back().contains("kick")):#and not  input_buffer.back().contains("s_kick") :
		
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
		charging_laser = false
		if current_start_projectile:
				current_start_projectile.deactivate()
				
		GDSync.call_func(store_last_used_move,[last_used_move])
		
	jump_code()

var book_fire_time : float = 0.0

func _physics_process(delta: float) -> void:
	mp = 600
	super._physics_process(delta)
	
	if not GDSync.is_gdsync_owner(self) or lag: return
	
	book_fire_time -= delta
	
	if is_on_floor() and charging_laser and not (is_mapped_action_pressed("move_right") or is_mapped_action_pressed("move_left")) and not (is_input_pressed("move_right") or is_input_pressed("move_left")):
		if current_start_projectile != null and charging_laser:
			current_start_projectile.charge(global_position)
			flash_charge()
			print("flash chargeaaaaaaaaaaa")
			charging_mp = false
			pass
	elif charging_laser:
		charging_laser = false
		charging_mp = true
		online_tint_sprite(Color.WHITE)
		if GameManager.online: GDSync.call_func(online_tint_sprite,[Color.WHITE])
		
	if is_on_floor() and not crouching:
		
		if not ai_player: book_laser()
		else: ai_book_laser()
		

		

		if not ai_player and is_mapped_action_pressed("s_kick") :
				if enough_mp(fire_cost):
					if crouching and book_fire_time <= 0.0:
						var fire_projectile = instanciate_fire(global_position + Vector2(0,-200))
						GDSync.call_func(instanciate_fire)
						fire_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,self)
						add_lag(30)
						book_fire_time = 1.5
						
						if direction == "left": fire_projectile.speed = 900
						else:  fire_projectile.speed = -900
						fire_projectile.speedY = 500
						
					elif not is_on_floor():
						var fire_projectile = instanciate_fire()
						GDSync.call_func(instanciate_fire)
						fire_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,self)
						
						#air impulse
						if velocity.y > 400:
							velocity.y -= 1800
						else:
							velocity.y -= 400
						
						fire_projectile.speed = 0
						fire_projectile.speedY = 550
						fire_projectile.acceleration.y = 20
						
						add_lag(30)
			
		elif ai_player and is_joy_button_just_pressed("s_kick"):
				
				if enough_mp(fire_cost):
					if crouching and book_fire_time <= 0.0:
						var fire_projectile = instanciate_fire(global_position + Vector2(0,-200))
						GDSync.call_func(instanciate_fire)
						fire_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,self)
						add_lag(30)
						book_fire_time = 1.5
						
						if direction == "left": fire_projectile.speed = 900
						else:  fire_projectile.speed = -900
						fire_projectile.speedY = 500
						
					elif not is_on_floor():
						var fire_projectile = instanciate_fire()
						GDSync.call_func(instanciate_fire)
						fire_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,self)
						
						#air impulse
						if velocity.y > 400:
							velocity.y -= 1800
						else:
							velocity.y -= 400
						
						fire_projectile.speed = 0
						fire_projectile.speedY = 550
						fire_projectile.acceleration.y = 20
						
						add_lag(30)
	
	
	

	if not ai_player and input_buffer.size() > 0 and input_buffer.back().contains("s_punch"):
				clear_buffer()
				await get_tree().create_timer(0.01667 * BOOK_PROJECTILE_STARTUP).timeout
		
				if enough_mp(projectile_cost):
					
					var pos_offset : Vector2 = Vector2(180, -160)
					if crouching: pos_offset = Vector2(200,60)
					if not is_on_floor(): pos_offset = Vector2(150,110)
					
					var book_proj = instanciate_book_projectile(global_position + pos_offset)
					GDSync.call_func(instanciate_book_projectile, [global_position + pos_offset])
					
					book_proj.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,null)
					
					if not is_on_floor():
						book_proj.speed = 1000
						book_proj.speedY = 800
					
					add_lag(20)
			
	elif ai_player and input_buffer.size() > 0 and input_buffer.back().contains("s_punch"):
				clear_buffer()
				await get_tree().create_timer(0.01667 * BOOK_PROJECTILE_STARTUP).timeout
				
				if enough_mp(projectile_cost):
					
					var pos_offset : Vector2 = Vector2(180, -160)
					if crouching: pos_offset = Vector2(200,60)
					if not is_on_floor(): pos_offset = Vector2(150,110)
					
					var book_proj = instanciate_book_projectile(global_position + pos_offset)
					GDSync.call_func(instanciate_book_projectile,[global_position + pos_offset])
					
					book_proj.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,null)
					
					if not is_on_floor():
						book_proj.speed = 1000
						book_proj.speedY = 800
					
					add_lag(20)
	
	#if not input_buffer.is_empty() and input_buffer.back().contains("s_punch"):
		#instanciate_projectile("res://Scenes/projectiles/orbiting_book.tscn","", Vector2(200,0), self)
		#input_buffer.clear()
	#
	return	


func book_laser():
		if is_mapped_action_pressed("s_kick") and current_start_projectile == null and  is_on_floor() and not charging_laser :
			
			while is_mapped_action_pressed("s_kick"):
				await get_tree().create_timer(0.0167).timeout
				
			if current_start_projectile == null:
				current_start_projectile = instanciate_star()
				#GDSync.set_gdsync_owner(current_start_projectile,GDSync.get_client_id())
				GDSync.call_func(instanciate_star)
				charging_laser = true
				started_charge = false	
		
		elif current_start_projectile  and is_mapped_action_pressed("s_kick"):
			add_lag(20)
			await get_tree().create_timer(0.0167 * 20).timeout
			shoot_laser()
			

func shoot_laser():
	current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	sprite_2d.modulate = Color.WHITE
	if GameManager.online: GDSync.call_func(online_tint_sprite, [Color.WHITE])
	current_start_projectile = null
	charging_laser = false
	add_lag(10)

func ai_book_laser():
		if is_input_pressed("s_kick") and current_start_projectile == null and  is_on_floor() and not charging_laser:

			while is_input_pressed("s_kick"):
				await get_tree().create_timer(0.0167).timeout
				
			if current_start_projectile == null:
				current_start_projectile = instanciate_star()
				#GDSync.set_gdsync_owner(current_start_projectile,GDSync.get_client_id())
				GDSync.call_func(instanciate_star)
				charging_laser = true
				started_charge = false	
		
		elif current_start_projectile   and is_input_pressed("s_kick"):
			
			add_lag(20)
			await get_tree().create_timer(0.0167 * 20).timeout
			shoot_laser()
			
			


func ai_on_hit():

	
	if hit_position == "body" and not blocked and not crouching :
		var action_id : int = randi_range(0,2)
		if action_id == 0:
			ai_press_input("crouch",randi_range(70,200))
		elif action_id == 1:
			var atk_id = randi_range(0,4)
				
			match atk_id:
					0:
						ai_press_input("s_punch")
					1:
						ai_press_input("w_punch")
					2:
						ai_press_input("s_kick")
					3: 
						ai_press_input("w_kick")
					4:
						ai_press_input("crouch",30)
		else:
			
			var current_state = $AI_StateMachine.current_state.name
			
			if current_state == "camp":
				var approach_id = randi_range(0,1)
				if approach_id == 0: $AI_StateMachine.on_child_transition($AI_StateMachine.current_state, "approach")
				else:
					ai_press_input("move_" + direction,30) #run away
			else:
				$AI_StateMachine.on_child_transition($AI_StateMachine.current_state, "camp")
			pass

var flash_frames = 12

func flash_charge():
	flash_frames -= 1
	
	if flash_frames <= 0:
		if sprite_2d.modulate == Color.WHITE:
			sprite_2d.modulate = Color.AQUA
			if GameManager.online: GDSync.call_func(online_tint_sprite, [Color.AQUA])
		else:
			sprite_2d.modulate = Color.WHITE
			if GameManager.online: GDSync.call_func(online_tint_sprite, [Color.WHITE])
			
		flash_frames = 12

func online_tint_sprite(color : Color):
	sprite_2d.color = color
