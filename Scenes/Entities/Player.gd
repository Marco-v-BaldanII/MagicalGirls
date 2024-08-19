extends CharacterBody2D
class_name Player

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = $StateMachine
@onready var hp_bar: ProgressBar = $CanvasLayer/hpBar
@onready var node_instantiator := $NodeInstantiator

#if an attack hits below this position it breacks guard
const DOWN_HIT_POS_THRESHOLD : int = 860

@export var hp : int = 100:
	set(value ):
		hp = clamp(value,0,100)
		
		while hp_bar.value != hp:
			hp_bar.value = lerp(hp_bar.value, float(hp), 0.75)
			await get_tree().create_timer(0.1667).timeout
			

@export var player_id : int = 0
@export var fly : bool = true

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
@export var direction : String = "left"
var input_direction : float = 0

const BUFFER_FRAMES = 16

var grounded : bool = false
var crouching : bool = false
var buffer_time =  0.01666 * BUFFER_FRAMES 
var jump_lag = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.2

var strong_knock : bool = false
var moving_backwards : bool = false

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"crouch" : false,
	"jump" : false,
	"w_punch" : false,
	"s_punch" : false,
	"w_kick" : false,
	"s_kick" : false
}
@onready var hit_box_1: Area2D = $hit_boxes/weak_box
@onready var hit_box_2: Area2D = $hit_boxes/strong_box
@onready var hurt_box: Area2D = $hurt_box
@onready var head_hurt_box: Area2D = $head_hurt_box

@onready var feet: CollisionShape2D = $Feet


var colliders : Array[CollisionShape2D]



func _ready():
	name = character_name

	set_hitboxes(player_id)
	GameManager.players.push_back(self)

	var animation = $AnimationPlayer.get_animation("idle_anim")
	animation.loop_mode = Animation.LOOP_PINGPONG
	
	#Assign to each character their moveset
	moveset = MovesetManager.movesets[character_name].duplicate()
	
	if  oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	
	GDSync.expose_node(self)
	GDSync.expose_func(online_instantiate)


func _process(delta):
	if input_made:
		buffer_time -= delta
	
		if buffer_time <= 0:
			clear_buffer()
		
	#Auto turn around logic
	if direction == "left" and oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	elif direction == "right" and oponent and oponent.global_position.x > global_position.x:
		scale.x *= -1
		direction = "left"

func _physics_process(delta):

	move_and_slide()

func is_joy_button_just_pressed(action_name : String):
	if action_state[action_name] == false and Input.is_joy_button_pressed(player_id, Controls.mapping[player_id][action_name]):
		action_state[action_name] = true
		return true
	if not Input.is_joy_button_pressed(player_id, Controls.mapping[player_id][action_name]):
		action_state[action_name] = false
	return false

var joy_x : float
var joy_y : float

func _input(event):
	
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
		
	
func add_input_to_buffer(input : String):
	if input_buffer.size() == 0 or input_buffer.back() != input:
		buffer_time =  0.01666 * BUFFER_FRAMES
		input_buffer.push_back(input)
		input_made = true


func perform_move():
	for specials in moveset:
		if moveset[specials].size() <= input_buffer.size() and  has_subarray(moveset[specials], input_buffer):
			var dir = find_special_direction(moveset[specials])
			if dir != direction:
				print(specials + dir)
				
				if FileAccess.file_exists("res://Scenes/projectiles/"+specials+".tscn"):
					var special_scene : PackedScene = load("res://Scenes/projectiles/"+specials+".tscn")

					GDSync.call_func(instanciate_projectile,["res://Scenes/projectiles/"+specials+".tscn"])
					instanciate_projectile("res://Scenes/projectiles/"+specials+".tscn")
					#Here will call the animation in the animation tree , which will have it's hitstun
				
			clear_buffer()

			return
			
	if input_buffer.back().contains("punch") or input_buffer.back().contains("kick"):
		var move : String = input_buffer.back()
		if is_on_floor() and not crouching:
			$AnimationTree["parameters/conditions/" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,[move])
		elif crouching:
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "crouch_" + move] = false
			
			clear_buffer()
			GDSync.call_func(_sync_move,["crouch_" + move])
		else:
			$AnimationTree["parameters/conditions/" + "air_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "air_" + move] = false
			clear_buffer()
			GDSync.call_func(_sync_move,["air_" + move])
			
	elif input_buffer.back().contains("jump") and is_on_floor() and not crouching:

		joy_x = Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X)
		print(joy_x)
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
	
func find_special_direction(special : Array[String]) -> String:
	for input in special:
		if input.contains("move"):
			if input == "move_right":
				return "right"
			else:
				return "left"
	return "none"

var hit : bool = false
var head: bool = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	
	hit = true
	sprite_2d.modulate = Color.RED
	
	var parent = area.get_parent()
	if parent.has_method("destroy_projectile"):
		parent.destroy_projectile()
	
	GameManager.camera_shake()
	
	if not head:
		var hit_pos : int = area.get_child(0).global_position.y

		print("I've been hit")
		
		if not crouching:
			
			if area.is_in_group("strong"):
				strong_knock = true
				GameManager.hit_stop_long()
				if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD and is_on_floor() :
					hp -= 4
					sprite_2d.modulate = Color.SKY_BLUE
				else:
					hp -= 15
			else:
				GameManager.hit_stop_short()
				strong_knock = false
				if moving_backwards and hit_pos < DOWN_HIT_POS_THRESHOLD  and is_on_floor() :
					hp -= 2
					sprite_2d.modulate = Color.SKY_BLUE
				else:
					hp -= 8
		else : #Hit body while crouching
			if area.is_in_group("strong"):
				GameManager.hit_stop_long()
				strong_knock = true
				hp -= 4
				sprite_2d.modulate = Color.SKY_BLUE
			else:
				GameManager.hit_stop_short()
				strong_knock = false
				sprite_2d.modulate = Color.SKY_BLUE
				hp -= 2
	else: #hit Head while crouching
		if crouching:
			
			if area.is_in_group("strong"):
				GameManager.hit_stop_long()
				strong_knock = true
				hp -= 15
			else:
				GameManager.hit_stop_short()
				strong_knock = false
				hp -= 8
				
	#Force a transition to the knocked state
	state_machine.on_child_transition(state_machine.current_state, "knocked")
	await get_tree().create_timer(0.017 * 20).timeout
	hit = false
	sprite_2d.modulate = Color.WHITE
		
func deactivate_collisions():
	pass


func _on_body_area_entered(area: Area2D) -> void:
	
	#Don't apply knock back if im not moving
	if input_direction != 0:
		oponent.strong_knock = true
		oponent.state_machine.on_child_transition(oponent.state_machine.current_state, "knocked")
		oponent.jump_lag = 0
		jump_lag = 0
	pass # Replace with function body.

var hurt_box_layer : int = 0

func set_hitboxes(player_id : int):
	if player_id == 0:
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
	print(anim_name + "01")
	if anim_name.contains("crouch"):
		if  (not Input.is_joy_button_pressed(player_id, Controls.mapping[player_id]["crouch"]) and 
		not(joy_y >  0.4  and abs(joy_x) < 0.2)) and not animation_player.current_animation.contains("crouch"):
			
			animation_tree["parameters/conditions/crouch"] = false
			animation_tree["parameters/conditions/not_crouch"] = true
			await get_tree().create_timer(0.017 * 6).timeout
			animation_tree["parameters/conditions/not_crouch"] = false
	pass # Replace with function body.


func _on_head_area_entered(area: Area2D) -> void:
	head = true
	_on_hurt_box_area_entered(area)
	head = false
	pass # Replace with function body.

func online_instantiate(special_scene : PackedScene):
	print("I have beeeeeeeen called")
	var instance = special_scene.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = global_position
	if oponent : instance.assign_phys_layer(player_id + 2, oponent.hurt_box_layer)
	
func instanciate_projectile(Pname : String):
	print("shit")
	var special_scene = load(Pname)
	var instance = special_scene.instantiate()
	get_tree().root.add_child(instance)
	instance.global_position = global_position
	if oponent : instance.assign_phys_layer(player_id + 2, oponent.hurt_box_layer)
