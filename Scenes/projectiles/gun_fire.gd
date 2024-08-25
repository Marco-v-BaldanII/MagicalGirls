extends Projectile
class_name GunFire

var active : bool = false

var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d = $Area2D
	hide()
	alive_time = 1.0
	GDSync.expose_node(self)
	dmg = 1
	speed = 1200
	scale = Vector2(0.2,0.2)
	set_physics_process(false)
	pass # Replace with function body.


func charge(position : Vector2):
	#GDSync.call_func(charge,[position])
	
	global_position = position
	
var _layer = 0
var _mask = 0
func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
	GDSync.call_func(assign_phys_layer,[layer,mask])
	_layer = layer; _mask = mask
	set_physics_process(true)
	$Area2D.set_monitoring(true)
	show()
	active = true
	assign_phys_layer(layer, mask)
	my_player = player
	global_position = my_player.position
	if dir == "right":
		speed *= -1
	if player:
		player.add_lag(lag_frames)



func destroy_projectile():
	#my_player.oponent.add_lag(4)

	if my_player: 
		my_player.oponent.weak_knock = true
		my_player.dead_bullets += 1
	await  get_tree().create_timer(0.017).timeout
	deativate()
	
func _physics_process(delta: float) -> void:
	position.x += speed * delta
	alive_time -= delta
	
	if alive_time < 0:
		destroy_projectile()
		pass
		
func deativate():
	$Area2D.set_collision_layer_value(_layer,false)
	$Area2D.set_collision_mask_value(_mask,false)
	$Area2D.set
	active = false
	hide()
	_ready()
