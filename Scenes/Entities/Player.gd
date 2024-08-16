extends CharacterBody2D
@onready var animation_player = $AnimationPlayer


const SPEED = 400.0
const JUMP_VELOCITY = -1500.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 3.2

func _ready():
	#set_physics_process(false)
	var animation = $AnimationPlayer.get_animation("idle_anim")
	animation.loop_mode = Animation.LOOP_PINGPONG


func _process(delta):
	if Input.is_action_pressed("ui_down"):
		animation_player.play("idle_anim")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction and is_on_floor():
		if direction > 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = direction * (SPEED*0.7)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
