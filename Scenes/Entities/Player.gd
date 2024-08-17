extends CharacterBody2D
class_name Player

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = $StateMachine
@onready var hp_bar: ProgressBar = $CanvasLayer/hpBar
@export var hp : int = 100:
	set(value ):
		hp = clamp(value,0,100)
		
		while hp_bar.value != hp:
			hp_bar.value = lerp(hp_bar.value, float(hp), 0.75)
			await get_tree().create_timer(0.1667).timeout
			

@export var player_id : int = 0

#These will get changet by a resource
@export var SPEED = 500.0
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

const BUFFER_FRAMES = 8

var grounded : bool = false

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
@onready var feet: CollisionShape2D = $Feet


var colliders : Array[CollisionShape2D]



func _ready():
	name = character_name
	
	if player_id == 0:
		hit_box_1.set_collision_layer_value(2, true)
		hit_box_2.set_collision_layer_value(2, true)
		hurt_box.set_collision_mask_value(3, true)

	else:
		hit_box_1.set_collision_layer_value(3, true)
		hit_box_2.set_collision_layer_value(3, true)
		hurt_box.set_collision_mask_value(2, true)


	#set_physics_process(false)
	var animation = $AnimationPlayer.get_animation("idle_anim")
	animation.loop_mode = Animation.LOOP_PINGPONG
	
	#Assign to each character their moveset
	moveset = MovesetManager.movesets[character_name].duplicate()
	
	if  oponent and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"



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

func _input(event):
	
	if is_joy_button_just_pressed("move_left"):
		add_input_to_buffer("move_left")
		perform_move()
	elif is_joy_button_just_pressed("move_right"):
		add_input_to_buffer("move_right")
		perform_move()
	elif is_joy_button_just_pressed("crouch"):
		add_input_to_buffer("crouch")
		perform_move()
	elif is_joy_button_just_pressed("jump"):
		add_input_to_buffer("jump")
		perform_move()
	elif is_joy_button_just_pressed("s_punch"):
		add_input_to_buffer("s_punch")
		perform_move()
	elif is_joy_button_just_pressed("w_punch"):
		add_input_to_buffer("w_punch")
		perform_move()
	elif is_joy_button_just_pressed("s_kick"):
		add_input_to_buffer("s_kick")
		perform_move()
	elif is_joy_button_just_pressed("w_kick"):
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
			clear_buffer()

			return
			
	if input_buffer.back().contains("punch") or input_buffer.back().contains("kick"):
		var move : String = input_buffer.back()
		if is_on_floor():
			$AnimationTree["parameters/conditions/" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + move] = false
			clear_buffer()
		else:
			$AnimationTree["parameters/conditions/" + "air_" + move] = true
			await get_tree().create_timer(0.017 * 6).timeout
			$AnimationTree["parameters/conditions/" + "air_" + move] = false
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

func _on_hurt_box_area_entered(area: Area2D) -> void:

		hit = true
		sprite_2d.modulate = Color.RED
		
		if area.is_in_group("strong"):
			strong_knock = true
			if not moving_backwards:
				hp -= 15
			else:
				hp -= 4
				sprite_2d.modulate = Color.SKY_BLUE
		else:
			strong_knock = false
			if not moving_backwards:
				hp -= 8
			else:
				hp -= 2
				sprite_2d.modulate = Color.SKY_BLUE
			
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
