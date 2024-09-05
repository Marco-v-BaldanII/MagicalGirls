extends CharacterBody2D
class_name FightingGameCamera

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	GameManager.camera = $Camera2D

var center_pos : int:
	get():
		return $Sprite2D.global_position.x

func _physics_process(delta: float) -> void:


	move_and_slide()
	
	velocity = Vector2.ZERO
	#velocity = velocity.move_toward(Vector2.ZERO, delta * 1000)
