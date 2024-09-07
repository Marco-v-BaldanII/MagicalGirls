extends CharacterBody2D
class_name Player

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = $StateMachine
@onready var hp_bar: TextureProgressBar =  $CanvasLayer/UI/hpBar_
@onready var mp_bar: TextureProgressBar = $CanvasLayer/UI/mpBar_

var charging_mp : bool = true

var match_setting : Match

var is_initialized : bool = false

@export var ai_player : bool = false

#if an attack hits below this position it breacks guard
const DOWN_HIT_POS_THRESHOLD : int = 860

signal player_died(player_id : int)

@export var hp : int = 100:
	set(value ):
		if GameManager.character_selection_mode == 4:
			return #no damagein training mode
		
		var difference = hp - value
		mp += difference * 5
		

		print("the hp was" + str(hp) + "but now is" + str(value))
		if GDSync.is_gdsync_owner(self): GDSync.call_func(change_hp,[value])
		hp = clamp(value,0,100)
		if hp_bar: 
			hp_bar.value = hp
			while hp_bar.value != hp:
				hp_bar.value = lerp(hp_bar.value, float(hp), 0.75)
				await get_tree().create_timer(0.1667).timeout
		
		if hp == 0:
			player_died.emit(oponent.player_num)
			
@export var mp : int = 200:
	set(value):
		if GameManager.character_selection_mode == 4:
			return #no damagein training mode
		mp = clamp(value,0,600)
		if GDSync.is_gdsync_owner(self) : GDSync.call_func(change_mp,[value])
		if mp_bar:
			mp_bar.value = mp
			

func change_hp(value : int):
	hp = clamp(value,0,100)
	if hp_bar : 
		hp_bar.value = hp
		while hp_bar.value != hp:
				hp_bar.value = lerp(hp_bar.value, float(hp), 0.75)
				await get_tree().create_timer(0.1667).timeout
			
func change_mp(value : int):
	mp = clamp(value,0,600)
	if mp_bar: mp_bar.value = mp

var player_num : int = 0 #player_num is 1 or 2 and is independent of online or offline unlike player_id 
@export var player_id : int = 0
@export var fly : bool = true


signal fully_instanciated

#These will get changet by a resource
@export var SPEED = 500.0
@export var FLY_SPEED = 700.0
@export var air_speed = 270
@export var JUMP_VELOCITY = -1500.0
@export var JUMP_LAG_FPS = 9
@export var character_name : String = "Ritsu"

var moveset : Dictionary
var input_buffer : Array[String]
var input_made : bool = false
@export var oponent : Player
@export var direction : String:
	set(value):
		direction = value
var input_direction : float = 0

const BUFFER_FRAMES = 10

const INPUT_EXTRA_BUFFER = 6

var grounded : bool = false
var crouching : bool = false
var buffer_time =  0.01666 * BUFFER_FRAMES 
var jump_lag = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.2

var strong_knock : bool = false
var weak_knock : bool = false
var moving_backwards : bool = false
var launch_knock : bool = false

var lag : bool = false:
	set(value):
		lag = value

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

enum INPUT_METHOD{
	CONTROLLER_1,
	CONTROLLER_2,
	KEYBOARD
}

var input_method : INPUT_METHOD = INPUT_METHOD.KEYBOARD:
	set(value):
		input_method = value

func is_input_pressed(input : String) -> bool:
	return action_state[input]

var authority : bool 

@export var move_dmg : Dictionary = {
	"w_punch" : 8,
	"s_punch" : 15,
	"crouch_w_punch" : 8,
	"crouch_s_punch" : 15,
	"air_w_punch" : 8,
	"air_s_punch" : 15,
	"w_kick" : 8,
	"s_kick" : 15,
	"crouch_w_kick" : 8,
	"crouch_s_kick" : 15,
	"air_w_kick" : 8,
	"air_s_kick" : 15
}

@export var move_vulnerable_on_shield : Dictionary = {
	"w_punch" : 15,
	"s_punch" : 30,
	"crouch_w_punch" : 15,
	"crouch_s_punch" : 30,
	"air_w_punch" : 15,
	"air_s_punch" : 30,
	"w_kick" : 15,
	"s_kick" : 30,
	"crouch_w_kick" : 15,
	"crouch_s_kick" : 30,
	"air_w_kick" : 15,
	"air_s_kick" : 30
}

var last_used_move : String

@onready var hit_box_1: Area2D = $hit_boxes/weak_box
@onready var hit_box_2: Area2D = $hit_boxes/strong_box
@onready var hurt_box: Area2D = $hurt_box
@onready var head_hurt_box: Area2D = $head_hurt_box

@onready var feet: CollisionShape2D = $Feet


var colliders : Array[CollisionShape2D]

@onready var weak_attack: CollisionShape2D = $hit_boxes/weak_box/weak_attack
@onready var strong_attack: CollisionShape2D = $hit_boxes/strong_box/strong_attack


func _ready():
	#weak_attack.disabled = true; strong_attack.disabled = true
	
	if player_num == 1:
		$PositionSynchronizer.broadcast = 0
	else: 
		$PositionSynchronizer.broadcast = 1
		
	
	direction = "left"
	await fully_instanciated
	can_move = true
	if GameManager.is_host and player_num == 1:
		GDSync.set_gdsync_owner(self,GDSync.get_client_id())
	elif not GameManager.is_host and player_num == 2:
		GDSync.set_gdsync_owner(self,GDSync.get_client_id())

	name = character_name
	GameManager.add_player(self)
	set_hitboxes(player_id)


	#var animation = $AnimationPlayer.get_animation("idle_anim")
	#animation.loop_mode = Animation.LOOP_PINGPONG
	
	#Assign to each character their moveset
	moveset = MovesetManager.movesets[character_name].duplicate()
	
	#if  oponent and oponent.global_position.x < global_position.x:
		#scale.x *= -1
		#direction = "right"
	#else: direction = "left"
	
	GDSync.expose_node(self)
	GDSync.expose_func(online_instantiate)

func calculate_direction():
	if direction == "left" and oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	elif direction == "right" and oponent and oponent.global_position.x > global_position.x:
		scale.x *= -1
		direction = "left"

var mp_timer : float = 0.75

func air_bump():
		if not is_on_floor():
			if direction == "left":
				velocity.x -= 100
				velocity.x = clamp(velocity.x,-300,0)
				move_and_slide()
				print("velocity invert")

			else:
				velocity.x += 100
				velocity.x = clamp(velocity.x,0,300)
				move_and_slide()
				print("velocity invert")
			print(velocity.x)


func _process(delta):
	if on_body:
		air_bump()
		
	mp_timer -= delta
	if mp_timer <= 0.0 and charging_mp:
		mp += 10
		mp_timer = 0.75
	
	if input_made:
		buffer_time -= delta
	
		if buffer_time <= 0 and (input_buffer.size() > 0 and (input_buffer.back().contains("punch") or input_buffer.back().contains("kick"))):
			if input_buffer.size() > 0: perform_move()
			clear_buffer()
		elif buffer_time <= -(0.0167 * INPUT_EXTRA_BUFFER):
			if input_buffer.size() > 0: perform_move()
			clear_buffer()
		
	#Auto turn around logic
	if direction == "left" and oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	elif direction == "right" and oponent and oponent.global_position.x > global_position.x:
		scale.x *= -1
		direction = "left"
		
	#if not crouching and animation_tree["parameters/conditions/not_crouch"] == false:
		#animation_tree["parameters/conditions/not_crouch"] = true
	#if not can_move and not crouching and is_on_floor() and not lag and animation_player.current_animation == "idle_anim":
		#can_move = true

func _physics_process(delta):
	if not is_initialized: return
	
	#Safety conditions to prevent can't move softlock
	#if is_on_floor() and animation_tree["parameters/conditions/crouch"] == false and not can_move and animation_player.current_animation == "idle_anim":
				#can_move = true
				#crouching = false
				#
	#if not can_move and not crouching and is_on_floor() and not lag and animation_player.current_animation == "idle_anim":
		#can_move = true
	

	move_and_slide()
	#if not crouching and animation_tree["parameters/conditions/not_crouch"] == true and (animation_player.current_animation == "crouching" or animation_player.current_animation == ""):
		#animation_player.play("idle_anim")
	
	if not oponent: return
	
	var distance_to_cam : int = abs(global_position.x - match_setting.camera.center_pos)
	var distance_to_rival : int = abs(global_position.x - oponent.global_position.x)
	#var t = get_viewport().size.x
	#var d = DisplayServer.screen_get_size().x
	if distance_to_cam > DisplayServer.screen_get_size().x * 0.35 and velocity.x != 0:
		#moving frontwards
		if (direction == "left" and velocity.x > 0) or (direction == "right" and velocity.x < 0):
			#if far away from rival
			if distance_to_rival > DisplayServer.screen_get_size().x * 0.3:
				match_setting.camera.velocity.x = velocity.x*0.6
		
		#moving backwards
		elif velocity.x != 0 and distance_to_rival < DisplayServer.screen_get_size().x * 0.95:
			
			match_setting.camera.velocity.x = velocity.x*0.6


	

func is_joy_button_just_pressed(action_name : String) -> bool:
	if input_method != INPUT_METHOD.KEYBOARD:
		if action_state[action_name] == false and Input.is_joy_button_pressed( input_method, Controls.mapping[player_id][action_name][0]) :
			action_state[action_name] = true
			listen_for_not_input(action_name)
			return true
		if not Input.is_joy_button_pressed(input_method, Controls.mapping[input_method][action_name][0]):
			action_state[action_name] = false
		return false
	else:
		if action_state[action_name] == false and Input.is_physical_key_pressed(Controls.mapping[player_id][action_name][1]) :
			action_state[action_name] = true
			listen_for_not_input(action_name)
			return true
		if not Input.is_physical_key_pressed(Controls.mapping[player_id][action_name][1]):
			action_state[action_name] = false
		return false

func listen_for_not_input(action_name : String):
	if input_method != INPUT_METHOD.KEYBOARD:
		while Input.is_joy_button_pressed( input_method, Controls.mapping[player_id][action_name][0]) :
			await get_tree().create_timer(0.0167).timeout
		action_state[action_name] = false
	
	else:
		while  Input.is_physical_key_pressed(Controls.mapping[player_id][action_name][1]):
			await get_tree().create_timer(0.0167).timeout
		action_state[action_name] = false

func is_mapped_action_pressed(action_name : String) -> bool:
	if input_method != INPUT_METHOD.KEYBOARD:
		if Input.is_joy_button_pressed( input_method, Controls.mapping[player_id][action_name][0]):
			return true
		else:
			return false
			
	else:
		if Input.is_physical_key_pressed(Controls.mapping[player_id][action_name][1]):
			return true
		else:
			return false

var joy_x : float
var joy_y : float

func _input(event):
	if ai_player: return #CPUS don't receive input
	
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
		if is_joy_button_just_pressed("l_trigger"):
			add_input_to_buffer("l_trigger")
			perform_move()
		if is_joy_button_just_pressed("r_trigger"):
			add_input_to_buffer("r_trigger")
			perform_move()
	
func add_input_to_buffer(input : String):
	if input_buffer.size() == 0 or input_buffer.back() != input:
		buffer_time =  0.01666 * BUFFER_FRAMES
		input_buffer.push_back(input)
		input_made = true
		if GameManager.character_selection_mode == 4: #TrainingMode
			InputViewer.add_input(input, input_method)

var can_move :bool:
	set(value):
		can_move = value
	
func perform_move():
	for specials in moveset:
		if moveset[specials] is Array[String] and moveset[specials].size() <= input_buffer.size() and  has_subarray(moveset[specials], input_buffer):
			var dir = find_special_direction(specials)
			if dir != direction or dir == "none":
				print(specials + dir)
				
				if FileAccess.file_exists("res://Scenes/projectiles/"+specials+".tscn"):
					var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

					GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
					instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn", specials)
					
					add_lag(MovesetManager.movesets[name][specials + "_lag"])
					#Here will call the animation in the animation tree , which will have it's hitstun
				
			clear_buffer()

			return
			
	if input_buffer.back().contains("punch") or input_buffer.back().contains("kick"):
		var move : String = input_buffer.back()


		if is_on_floor() and not crouching:
			velocity.x = 0
			last_used_move = move
			can_move = false #Can't move while ground attacks
			$AnimationTree["parameters/conditions/" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,[move])
		elif crouching:
			can_move = false #Can't move while ground attacks
			
			last_used_move = "crouch_"+move
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = false
			
			clear_buffer()
			GDSync.call_func(_sync_move,["crouch_" + move])
			
			await get_tree().create_timer(0.01667*4)
			if is_on_floor() and not crouching and not can_move:
				can_move = true
			
		else:
			last_used_move = "air_" + move
			$AnimationTree["parameters/conditions/" + "air_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "air_" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,["air_" + move])
		GDSync.call_func(store_last_used_move,[last_used_move])
	elif input_buffer.back().contains("jump") and is_on_floor() and not crouching and jump_lag <= 0:

		joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
		state_machine.on_child_transition(state_machine.current_state, "air_move")

func _sync_move(animation : String):

	$AnimationTree["parameters/conditions/" + animation] = true
	await get_tree().create_timer(0.017 * 6).timeout
	$AnimationTree["parameters/conditions/" + animation] = false
	clear_buffer()

func has_subarray(array : Array, subarray : Array) -> bool:
	var subarray_size = subarray.size()
	var array_size = array.size()

	for i in range(array_size - subarray_size + 1):
		if array.slice(i, subarray_size) == subarray:
			return true

	return false

func clear_buffer():
	input_made = false
	buffer_time = 0.01666 * BUFFER_FRAMES
	print(input_buffer)
	input_buffer.clear()
	
func find_special_direction(special : String) -> String:

		if special.contains("right"):
			
				return "right"
		elif special.contains("left"):
				return "left"
		return "none"

var hit : bool = false
var head: bool = false

var blocked : bool = false

var hit_position : String 

var body : bool = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	
	if GameManager.online and not GDSync.is_gdsync_owner(self) and area.get_parent() is Projectile:
		return
	
	print("hit on " + str(area.global_position.y))
	
	hit_position = "none"
	hit = true
	
	var parent = area.get_parent()
	if parent.has_method("destroy_projectile"):
		parent.destroy_projectile()

	if not head:
		
		var hit_pos : int = area.get_child(0).global_position.y
		
		if not crouching:
			
			if area.is_in_group("strong"):
				strong_knock = true

				
				if area.has_method("get_dmg"):
					if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD and is_on_floor() :
						hp -= area.get_dmg()/3
						sprite_2d.modulate = Color.SKY_BLUE
						blocked = true
						oponent.add_lag(10)
					else:
						hp -= area.get_dmg()
						blocked = false
				else:
					if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD and is_on_floor() :
						hp -= oponent.move_dmg[oponent.last_used_move] /3
						sprite_2d.modulate = Color.SKY_BLUE
						oponent.add_lag(4)
						blocked = true
					else:
						blocked = false
						hp -= oponent.move_dmg[oponent.last_used_move]
						hit_position = "body"
			else:

				strong_knock = false
				if area.has_method("get_dmg"):
					
					if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD  and is_on_floor() :
						hp -= area.get_dmg()/3
						sprite_2d.modulate = Color.SKY_BLUE
						oponent.add_lag(10)
						blocked = true
					else:
						hp -= area.get_dmg()
						blocked = false
				else:
					if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD  and is_on_floor() :
						hp -= oponent.move_dmg[oponent.last_used_move] /3
						sprite_2d.modulate = Color.SKY_BLUE
						oponent.add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move])
						blocked = true
					else:
						hp -= oponent.move_dmg[oponent.last_used_move] 
						blocked = false
						hit_position = "body"
		else : #Hit body while crouching
			blocked = true
			if area.has_method("get_dmg"):
				if area.is_in_group("strong"):

					strong_knock = true
					hp -= area.get_dmg()/3
					sprite_2d.modulate = Color.SKY_BLUE
					#oponent.add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move])

				else:

					strong_knock = false
					sprite_2d.modulate = Color.SKY_BLUE
					#oponent.add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move])
					hp -= area.get_dmg() /3

			else:
				if area.is_in_group("strong"):

					strong_knock = true
					hp -= oponent.move_dmg[oponent.last_used_move] /3
					oponent.add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move])
					sprite_2d.modulate = Color.SKY_BLUE
				else:

					strong_knock = false
					sprite_2d.modulate = Color.SKY_BLUE
					oponent.add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move])
					hp -= oponent.move_dmg[oponent.last_used_move] /3
	else: #hit Head while crouching
		if crouching:
			blocked = false
			if area.has_method("get_dmg"):
				if area.is_in_group("strong"):
					GameManager.hit_stop_long()
					strong_knock = true
					hp -= area.get_dmg()
				else:
					GameManager.hit_stop_short()
					strong_knock = false
					hp -= area.get_dmg()
			else:
				if area.is_in_group("strong"):
					GameManager.hit_stop_long()
					strong_knock = true
					hp -= oponent.move_dmg[oponent.last_used_move]
					hit_position = "head"
				else:
					GameManager.hit_stop_short()
					strong_knock = false
					hp -= oponent.move_dmg[oponent.last_used_move] 
					hit_position = "head"
					
	#Force a transition to the knocked state
	if not blocked and area.is_in_group("special"):
		launch_knock = true
	else:
		launch_knock = false
	
	if  area.is_in_group("super_weak"):
		pass
	elif area.is_in_group("weak"):
		if not blocked : GameManager.camera_shake()
		GameManager.hit_stop_short()
		state_machine.on_child_transition(state_machine.current_state, "knocked")
	elif area.is_in_group("strong") or area.is_in_group("special"):
		if not blocked : GameManager.camera_shake()
		GameManager.hit_stop_long()
		state_machine.on_child_transition(state_machine.current_state, "knocked")
	
	if not blocked and oponent.last_used_move != "":
		#add hitstun after getting hit
		add_lag(oponent.move_vulnerable_on_shield[oponent.last_used_move] * 2)
	show_tint(blocked)
	if GameManager.online:
		GDSync.call_func(show_tint, [blocked])
		GDSync.call_func(online_receive_dmg,[area])
	if ai_player: ai_on_hit()
	
	await get_tree().create_timer(0.017 * 20).timeout
	hit = false

	
func show_tint(block : bool):
	if block: sprite_2d.modulate = Color.AQUA
	else :sprite_2d.modulate = Color.RED
	await  get_tree().create_timer(0.017 * 20).timeout
	sprite_2d.modulate = Color.WHITE
		
func deactivate_collisions():
	pass

func online_receive_dmg(area : Area2D):
	hit = true
	sprite_2d.modulate = Color.RED
	
	if not area == null:
		var parent = area.get_parent()
		if parent.has_method("destroy_projectile"):
			parent.destroy_projectile()
	
	GameManager.camera_shake()
var on_body : bool = false



var hurt_box_layer : int = 0

func set_hitboxes(player_id : int):
	if player_num == 1:
		hit_box_1.set_collision_layer_value(2, true)
		hit_box_2.set_collision_layer_value(2, true)
		hurt_box.set_collision_mask_value(3, true)
		hurt_box.set_collision_layer_value(4,true)
		head_hurt_box.set_collision_mask_value(3,true)
		hurt_box_layer = 4

	else:
		hit_box_1.set_collision_layer_value(3, true)
		hit_box_2.set_collision_layer_value(3, true)
		hurt_box.set_collision_mask_value(2, true)
		hurt_box.set_collision_layer_value(5,true)
		head_hurt_box.set_collision_mask_value(2,true)
		hurt_box_layer = 5



func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	var joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
	var joy_y = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_Y)
	
		#make it so that you CAN move after the animation has finished
	if anim_name.contains("punch") or anim_name.contains("kick"):
		can_move = true

	if anim_name == "crouch" and GDSync.is_gdsync_owner(self) and not ai_player:
		if  (not is_mapped_action_pressed("crouch") and 
		not(joy_y >  0.4  and abs(joy_x) < 0.2)) and not animation_player.current_animation.contains("crouch") :
			
			stand_up()
			GDSync.call_func(stand_up)
		else:
			
			play_crouching()
			GDSync.call_func(play_crouching)
			
	elif anim_name == "crouch" and ai_player:
		
		if not is_input_pressed("crouch"):
			stand_up()
		else:
			play_crouching()
		
			#state_machine.on_child_transition(state_machine.current_state, "crouch")

func play_crouching():
	animation_tree["parameters/conditions/not_crouch"] = false
	animation_tree["parameters/conditions/crouching"] = true

func stand_up():
	#animation_player.play("idle_anim")
	animation_tree["parameters/conditions/crouch"] = false
	animation_tree["parameters/conditions/not_crouch"] = true
	await get_tree().create_timer(0.017 * 6).timeout
	animation_tree["parameters/conditions/not_crouch"] = false


func online_instantiate(special_scene : PackedScene):

	var instance = special_scene.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = global_position
	if oponent : instance.assign_phys_layer((player_num-1) + 2, oponent.hurt_box_layer)
	
func instanciate_projectile(path : String, p_name : String, position_offset : Vector2 = Vector2.ZERO, my_self : Player = null, shoot : bool = true, spawn : int = 1, start_pos : bool = false):
	if GameManager.online and GDSync.is_gdsync_owner(self):
		await get_tree().create_timer(0.0167*5).timeout
	if p_name == "anastasia_ulti": my_self = null
	var instance = projectile_instanciation(path, p_name, position_offset, my_self , shoot,spawn, start_pos)
	GDSync.call_func(projectile_instanciation,[path, p_name, position_offset, my_self, shoot,spawn, start_pos])
	
	return instance
	
func projectile_instanciation(path : String, p_name : String, position_offset : Vector2 = Vector2.ZERO, my_self : Player = null, shoot : bool = true, spawn : int = 1, start_pos : bool = true):
	var special_scene = load(path)
	var instance = special_scene.instantiate()
	
	instance.online_synch(player_id)
	
	if my_self == null :
		if spawn == 1:
			GameManager.p1_spawns.add_child(instance)
		else:
			GameManager.p2_spawns.add_child(instance)
	else: 
		my_self.add_child(instance)
	
	if start_pos:
		instance.global_position = global_position
		
		instance.global_position += position_offset
	else:
		instance.global_position = GameManager.camera.get_parent().global_position
		
	var startup : int = 0
	if p_name != "": startup = MovesetManager.movesets[character_name][p_name + "_startup"]
	
	if instance.has_method("shoot") and shoot:
		if oponent : instance.shoot((player_num-1) + 2, oponent.hurt_box_layer, direction, self,startup)
		else: instance.shoot((player_num-1) + 2, 0 , direction, self, startup)
	return instance

func store_last_used_move(move:String):
	last_used_move = move

signal lag_finished

func add_lag(frames : int):
	if frames == 0: return
	
	if is_on_floor():
		velocity.x = 0
		input_direction = 0
		input_buffer.clear()
	
	#while lag:
		#await get_tree().create_timer(0.01667).timeout
	lag = false
	print(str(frames) + "lag")
	lag = true
	set_process_input(false)
	
	await get_tree().create_timer(0.01667 * frames).timeout
	lag = false
	
	lag_finished.emit()
	
	set_process_input(true)

func shoot_projectile_wrap(projectile : Projectile):
	shoot_projectile(projectile)
	GDSync.call_func(shoot_projectile,[projectile])

func shoot_projectile(projectile : Projectile):
	projectile.shoot((player_num-1) + 2, oponent.hurt_box_layer,direction, self)

func ai_on_hit():

	
	if hit_position == "body" and not blocked and not crouching :
		var action_id : int = randi_range(0,1)
		if action_id == 0:
			ai_press_input("crouch",randi_range(70,200))
		else:
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
			pass

func ai_press_input(input : String, frames : float = 1):
	if input.contains("kick") or input.contains("punch"): last_used_move = input
	action_state[input] = true
	input_buffer.push_back(input)
	perform_move()
	await get_tree().create_timer(0.01667 * frames).timeout
	action_state[input] = false

func choose_random_special() -> Array[String]:
							# Choose a random special
						var current_scpecial : Array[String]
						input_buffer.clear()
						
						var possible_specials : Array[String]
						
						for special in moveset:
							if moveset[special] is Array[String]  and direction != find_special_direction(special):
								
								possible_specials.push_back(special)
								
						return possible_specials

func enough_mp(atk_mp : int)-> bool:
	if atk_mp <= mp:
		mp -= atk_mp
		return true
	else:
		
		flash_mp_bar()
		return false
		
		
func flash_mp_bar():
	var i = 3
	while i > 0:
		mp_bar.modulate = Color.RED
		await get_tree().create_timer(0.017 * 6).timeout
		mp_bar.modulate = Color.WHITE
		await get_tree().create_timer(0.017 * 6).timeout
		i -= 1


func _on_body_area_exited(area: Area2D) -> void:
	
	on_body = false
	pass # Replace with function body.

func _on_body_area_entered(area: Area2D) -> void:
	on_body = true

	if input_direction != 0 and is_on_floor():
		oponent.strong_knock = true
		oponent.state_machine.on_child_transition(oponent.state_machine.current_state, "knocked")
		oponent.jump_lag = 0
		jump_lag = 0
	#Don't apply knock back if im not moving
	
	pass # Replace with function body.
