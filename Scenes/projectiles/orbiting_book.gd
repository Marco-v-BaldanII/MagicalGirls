extends Projectile
class_name OrbitingBook

var radius : int = 0

func _ready() -> void:
	super()


func _physics_process(delta: float) -> void:
	if radius == 0:
			var vector_p : Vector2 = global_position - my_player.global_position
			radius = vector_p.length()
	
	var vector_p : Vector2 = global_position - my_player.global_position
	
	var perpendicular_v = vector_p.orthogonal().normalized()  * speed
	

	
	var Nspeed = perpendicular_v.x 
	var NspeedY = perpendicular_v.y 
	
	global_position.x += Nspeed  * delta
	global_position.y += NspeedY  * delta
	
	# Ensure the object stays at a constant distance from the player
	# Reproject the position back to the circle with the original radius

	vector_p = global_position - my_player.global_position
	global_position = my_player.global_position + vector_p.normalized() * radius
	
	alive_time -= delta

	if alive_time < 0:
		queue_free()
	

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
	set_physics_process(true)
	show()
	assign_phys_layer(layer, mask)
	if dir == "right":
		speed *= -1
	if player:
		my_player = player
		global_position = player.global_position
		position.x += 200

	GDSync.call_func(shoot, [layer,mask,dir,player])

func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
func _on_area_2d_area_entered(area: Area2D) -> void:

	
	if area.is_in_group("projectile"):
		queue_free()
