extends CharacterBody2D
@onready var animation_player = $AnimationPlayer

@export var player_id : int = 0

#These will get changet by a resource
@export var SPEED = 500.0
@export var JUMP_VELOCITY = -1500.0

var moveset : Dictionary
var input_buffer : Array[String]
var input_made : bool = false

const BUFFER_FRAMES = 8

var buffer_time =  0.01666 * BUFFER_FRAMES 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.2

func _ready():
	name = "Ritsu"
	#set_physics_process(false)
	var animation = $AnimationPlayer.get_animation("idle_anim")
	animation.loop_mode = Animation.LOOP_PINGPONG
	
	#Assign to each character their moveset
	moveset = MovesetManager.movesets[name].duplicate()


func _process(delta):
	
	if input_made:
		buffer_time -= delta
	
		if buffer_time <= 0:
			clear_buffer()
		
	
	#if Input.is_action_pressed("ui_down"):
		#animation_player.play("idle_anim")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction and is_on_floor():
		if direction > 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = direction * (SPEED*0.7)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


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

func is_joy_button_just_pressed(action_name : String):
	if action_state[action_name] == false and Input.is_joy_button_pressed(player_id, Controls.mapping[player_id][action_name]):
		action_state[action_name] = true
		return true
		
	action_state[action_name] = false
	return false

func _input(event):
	
	if Input.is_action_just_pressed("move_left"):
		add_input_to_buffer("move_left")
		perform_move()
	elif Input.is_action_just_pressed("move_right"):
		add_input_to_buffer("move_right")
		perform_move()
	elif Input.is_action_just_pressed("crouch"):
		add_input_to_buffer("crouch")
		perform_move()
	elif Input.is_action_just_pressed("jump"):
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
