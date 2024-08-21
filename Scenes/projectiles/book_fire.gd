extends Projectile
class_name BookFire

var moving : bool = true
var speed_y

func _ready() -> void:
	speed_y = speed*0.7

func _physics_process(delta: float) -> void:
	

	if alive_time < 0:
		queue_free()
		
	if moving:
		position.x += speed * delta
		position.y += speed_y * delta
	else:
		alive_time -= delta

func assign_phys_layer(layer : int, mask : int):
	if not area_2d: area_2d = $Area2D
	area_2d.set_collision_layer_value(layer,true)
	area_2d.set_collision_mask_value(mask,true)

func shoot(layer : int , mask : int, dir : String, player : Player = null):
	GDSync.call_func(assign_phys_layer,[layer,mask])
	set_physics_process(true)
	assign_phys_layer(layer, mask)

	if dir == "right":
		speed *= -1
	else:
		pass
	if player:
		player.add_lag(lag_frames)

func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	await get_tree().create_timer(0.01667*5).timeout
	moving = false
	pass # Replace with function body.
