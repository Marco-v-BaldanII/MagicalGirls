extends Sprite2D
class_name Projectile

@export var alive_time : float = 5
@export var lag_frames : int = 20
@onready var area_2d: Area2D = $Area2D
@export var speed = 400

@export var dmg : float = 8

func _physics_process(delta: float) -> void:
	alive_time -= delta

	if alive_time < 0:
		queue_free()
		
	position.x += speed * delta

func assign_phys_layer(layer : int, mask : int):
	if not area_2d: area_2d = $Area2D
	area_2d.set_collision_layer_value(layer,true)
	area_2d.set_collision_mask_value(mask,true)



func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
	
