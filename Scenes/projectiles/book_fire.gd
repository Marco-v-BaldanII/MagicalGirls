extends Projectile
class_name BookFire

var moving : bool = true
var acceleration : Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	

	if alive_time < 0:
		queue_free()
		
	if moving:
		position.x += speed * delta
		position.y += speedY * delta
		
		speed += acceleration.x
		speedY += acceleration.y
	else:
		alive_time -= delta

func assign_phys_layer(layer : int, mask : int):
	if not area_2d: area_2d = $Area2D
	area_2d.set_collision_layer_value(layer,true)
	if layer == 2: area_2d.set_collision_mask_value(3,true)
	else: area_2d.set_collision_mask_value(2,true)
	area_2d.set_collision_mask_value(mask,true)

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
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
	
	if body.is_in_group("floor"):
		await get_tree().create_timer(0.01667*5).timeout
		moving = false
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		collide_with_projectile(area)
	else:
		pass # Replace with function body.
