extends Player
class_name EllieQuinn

var current_start_projectile : Projectile
const STAR_RIGHT = preload("res://Scenes/projectiles/book_laser.tscn")
const BOOK_FIRE = preload("res://Scenes/projectiles/book_fire.tscn")

const ORBITING_BOOK = preload("res://Scenes/projectiles/orbiting_book.tscn")

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

func _input(event):

	
	if not can_move: return
	
	if not GameManager.online or GDSync.is_gdsync_owner(self):
		if input_method != 2:
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
	charging_laser = true
	return current_start_projectile
	
	
func instanciate_fire():
	var projectile = BOOK_FIRE.instantiate()
	#current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	projectile.global_position = global_position
	projectile.global_position.y -= 200
	get_tree().root.add_child(projectile)
	
	return projectile
	
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
				
				if FileAccess.file_exists("res://Scenes/projectiles/"+specials+".tscn"):
					var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

					#GDSync.call_func(instanciate_projectile_online,["res://Scenes/projectiles/"+specials+".tscn"])
					instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn", specials)
					
					add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
					#Here will call the animation in the animation tree , which will have it's hitstun
				
			clear_buffer()

			return
			
	if (input_buffer.back().contains("punch") or input_buffer.back().contains("kick"))and not  input_buffer.back().contains("s_kick") :
		
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
		
	elif  input_buffer.is_empty() == false and input_buffer.back().contains("jump") and is_on_floor() and not crouching:
			if input_method != 2:
				joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)

			state_machine.on_child_transition(state_machine.current_state, "air_move")



func _physics_process(delta: float) -> void:
	
	super._physics_process(delta)
	
	if not GDSync.is_gdsync_owner(self) or lag: return
	
	if is_on_floor() and charging_laser and not (is_mapped_action_pressed("move_right") or is_mapped_action_pressed("move_left")):
		if current_start_projectile != null and charging_laser:
			current_start_projectile.charge(global_position)
			pass
	elif charging_laser:
		charging_laser = false
	if is_on_floor() and not crouching:
		
		book_laser()
		
		
	elif is_on_floor() and crouching:
		
		if is_mapped_action_pressed("s_kick") and current_start_projectile == null:
			var fire_projectile = instanciate_fire()
			GDSync.call_func(instanciate_fire)
			fire_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction,self)
			add_lag(30)
			pass
	
	
	#if not input_buffer.is_empty() and input_buffer.back().contains("s_punch"):
		#instanciate_projectile("res://Scenes/projectiles/orbiting_book.tscn","", Vector2(200,0), self)
		#input_buffer.clear()
	#
	return	


func book_laser():
		if is_mapped_action_pressed("s_kick") and current_start_projectile == null and  is_on_floor() and not charging_laser :

			var star = instanciate_star()
			GDSync.set_gdsync_owner(star,GDSync.get_client_id())
			GDSync.call_func(instanciate_star)
			charging_laser = false
			started_charge = true	
		
		if not charging_laser and started_charge and not is_mapped_action_pressed("s_kick"):
			
			charging_laser = true
			started_charge = false
			
		elif not charging_laser and not started_charge and is_mapped_action_pressed("s_kick"):
			charging_laser = false; started_charge = true;

		elif current_start_projectile and charging_laser  and is_mapped_action_pressed("s_kick"):
			
			shoot_laser()
			

func shoot_laser():
	current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	
	current_start_projectile = null
	charging_laser = false
	add_lag(10)
