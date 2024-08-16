extends CharacterBody2D
class_name Player

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var player_id : int = 0

#These will get changet by a resource
@export var SPEED = 500.0
@export var JUMP_VELOCITY = -1500.0
@export var JUMP_LAG_FPS = 7
@export var character_name : String = "Ritsu"

var moveset : Dictionary
var input_buffer : Array[String]
var input_made : bool = false
@export var oponent : Player
@export var direction : String = "left"

const BUFFER_FRAMES = 8

var grounded : bool = false

var buffer_time =  0.01666 * BUFFER_FRAMES 
var jump_lag = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.2

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

func _ready():
	name = character_name
	#set_physics_process(false)
	var animation = $AnimationPlayer.get_animation("idle_anim")
	animation.loop_mode = Animation.LOOP_PINGPONG
	
	#Assign to each character their moveset
	moveset = MovesetManager.movesets[name].duplicate()
	
	if  oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"



func _process(delta):
	
	if input_made:
		buffer_time -= delta
	
		if buffer_time <= 0:
			clear_buffer()
		
	#Auto turn around logic
	if direction == "left" and oponent.global_position.x < global_position.x:
		scale.x *= -1
		direction = "right"
	elif direction == "right" and oponent.global_position.x > global_position.x:
		scale.x *= -1
		direction = "left"

func _physics_process(delta):
	if not is_on_floor() :
		grounded = false
		
	#LAND	
	if is_on_floor() and not grounded:
		$AnimationTree["parameters/conditions/land"] = true
		grounded = true
		jump_lag = 0.01666 * JUMP_LAG_FPS
		await get_tree().create_timer(0.017 * 6).timeout
		$AnimationTree["parameters/conditions/land"] = false
	
	# Add the gravity.
	if not is_on_floor() :
		velocity.y += gravity * delta

	if input_buffer.has("jump") and is_on_floor() and jump_lag <= 0:
		velocity.y = JUMP_VELOCITY
		if input_buffer.has("move_left"):
			velocity.x = -SPEED*0.7
		elif input_buffer.has("move_right"):
			velocity.x = SPEED*0.7

	var _direction : int = 0
	if Input.is_joy_button_pressed(player_id, Controls.mapping[player_id]["move_right"]):
		_direction += 1
	if Input.is_joy_button_pressed(player_id, Controls.mapping[player_id]["move_left"]):
		_direction -= 1
	if _direction and is_on_floor():
		jump_lag -= delta
		if(_direction > 0 and direction == "left") or (_direction < 0 and direction == "right"):
			velocity.x = _direction * SPEED
		else:
			#move slower in your back direction
			velocity.x = _direction * (SPEED*0.7)

	elif is_on_floor():
		jump_lag -= delta
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
	for specials in MovesetManager.movesets[name].keys():
		if moveset[specials].size() <= input_buffer.size() and  has_subarray(moveset[specials], input_buffer):
			
			clear_buffer()
			print(specials)

			return
			
	if input_buffer.back().contains("punch") or input_buffer.back().contains("kick"):
		var move : String = input_buffer.back()
		$AnimationTree["parameters/conditions/" + move] = true
		await get_tree().create_timer(0.017 * 6).timeout
		$AnimationTree["parameters/conditions/" + move] = false
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
