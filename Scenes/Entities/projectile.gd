extends Sprite2D
class_name Projectile

@export var alive_time = 5
@onready var area_2d: Area2D = $Area2D
@export var speed = 400

func _physics_process(delta: float) -> void:
	alive_time -= delta
	
	if alive_time < 0:
		queue_free()
		
	position.x += speed * delta

func assign_phys_layer(layer : int, mask : int):
	area_2d.set_collision_layer_value(layer,true)
	area_2d.set_collision_mask_value(mask,true)



func _on_area_2d_area_entered(area: Area2D) -> void:
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	pass # Replace with function body.

func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
