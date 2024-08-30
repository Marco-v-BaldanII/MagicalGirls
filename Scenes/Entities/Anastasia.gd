extends Player
class_name Anastasia

var current_start_projectile : Projectile
const GRENADE = preload("res://Scenes/projectiles/grenade.tscn")
const GUN_FIRE = preload("res://Scenes/projectiles/gun_fire.tscn")

@export var recharge_frames : int = 40
@export var fire_rate_frames : int = 12

signal recharge_AK

var dead_bullets :
	set(value):
		dead_bullets = value
		if dead_bullets == max_shots:
			recharge_AK.emit()

var AK : Array
@export var max_shots : int = 15
var current_shot :
	set(value):
		if value > max_shots-1:
			add_lag(recharge_frames)
			
			current_shot = 0
		else:
			current_shot = value
			

func _ready() -> void:
	current_shot = 0
	dead_bullets = 0
	super()
	await fully_instanciated
	
	if player_num == 1:
		$PositionSynchronizer.broadcast = 0
	else: $PositionSynchronizer.broadcast = 1
		
	for i in range(max_shots):
		AK.push_back(gun_fire())
		get_tree().root.add_child.call_deferred(AK.back())
	
	move_dmg["2knife_attack"] = 10
	move_vulnerable_on_shield["2knife_attack"] = 6
	
	sync_AK()

func sync_AK():
	if GameManager.online and GDSync.is_gdsync_owner(self):
		for A in AK:
		
			GDSync.set_gdsync_owner(A,GDSync.get_client_id())
			A.sync_broadcast(GDSync.get_client_id())

func _input(event):
	if not can_move: return
	
	if not GameManager.online or GDSync.is_gdsync_owner(self):
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
		
func instanciate_grenade():
	current_start_projectile = GRENADE.instantiate()
	get_tree().root.add_child(current_start_projectile)
	return current_start_projectile
	
	
func gun_fire():
	current_start_projectile = GUN_FIRE.instantiate()
	current_start_projectile.assign_phys_layer((player_num-1) + 2, oponent.hurt_box_layer)
	#current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
	current_start_projectile.global_position = global_position
	#get_tree().root.add_child(current_start_projectile)
	
	return current_start_projectile
	#current_start_projectile = null
	
func perform_move():
	if not can_move and not lag: return
	#
	#velocity.x = 0
	
	for specials in moveset:
			if  moveset[specials] is Array[String] and moveset[specials].size() <= input_buffer.size()  and  has_subarray(moveset[specials], input_buffer):
				var dir = find_special_direction(specials)
				if dir != direction:
					print(specials + dir)
					
					if FileAccess.file_exists("res://Scenes/projectiles/"+specials+".tscn"):
						var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

						#GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
						instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn",specials)
						
						clear_buffer()
						
						await lag_finished
						
						add_lag(MovesetManager.movesets[character_name][specials + "_lag"])
						return
						#Here will call the animation in the animation tree , which will have it's hitstun
					else:
						#this means that the special is a melee attack
						last_used_move =  specials
						can_move = false #Can't move while ground attacks
						$AnimationTree["parameters/conditions/" + specials] = true
						await get_tree().create_timer(0.017 * 6).timeout
						$AnimationTree["parameters/conditions/" + specials] = false
						clear_buffer()
						GDSync.call_func(_sync_move,[specials])
						
						
						return
			
	if (input_buffer.back().contains("punch") or input_buffer.back().contains("kick"))and not  input_buffer.back().contains("s_kick") and not input_buffer.back().contains("s_punch"):
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
			can_move = false
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
		
	elif input_buffer.back().contains("s_kick") and current_start_projectile == null :

		var grenade = instanciate_projectile("res://Scenes/projectiles/grenade.tscn","",Vector2.ZERO ,null , false, player_num)
		current_start_projectile = grenade
		#var grenade = instanciate_grenade()
		GDSync.set_gdsync_owner(grenade,GDSync.get_client_id())
		#GDSync.call_func(instanciate_grenade)


		
	elif input_buffer.back().contains("jump") and is_on_floor() and not crouching:

			
		joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)

		state_machine.on_child_transition(state_machine.current_state, "air_move")


func _physics_process(delta: float) -> void:
		
	
		super._physics_process(delta)
		if not GDSync.is_gdsync_owner(self) or lag: return
		
		if  is_mapped_action_pressed("s_punch") and not lag:
			#get_tree().root.add_child(AK[current_shot])
			var has_shot : bool = false
			for i in AK.size():
				if not AK[i].active:
					#AK[i].shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
					shoot_projectile_wrap(AK[i])
					has_shot = true
					current_shot += 1
					break
			
			#AK[current_shot].shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)
			


		if current_start_projectile != null and is_mapped_action_pressed("s_kick"):
			current_start_projectile.charge(global_position)
			#the fixed update is "charging" the grenade

		elif current_start_projectile != null and oponent:
			current_start_projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)

			if crouching: 
				#The crouching grenade get's thrown at a more horizontal lower angle
				current_start_projectile.speed *= 2
				current_start_projectile.og_speedX *= 2
				current_start_projectile.speedY *= 0.6
				
			current_start_projectile = null
			
