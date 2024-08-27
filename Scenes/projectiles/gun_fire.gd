extends Projectile
class_name GunFire


var is_visible : bool:
	set(value):
		if value != is_visible:
			is_visible = value
			if not is_visible:
				hide()
				$Area2D.monitorable = false
			else:
				show()
				$Area2D.monitorable = true
	
var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_visible = true
	GameManager.joined_lobby.connect(_ready)
	
	area_2d = $Area2D
	is_visible = false
	alive_time = 1.0
	GDSync.expose_node(self)
	dmg = 1
	speed = 1200
	scale = Vector2(0.2,0.2)
	set_physics_process(false)	
	#$Area2D.monitoring = false
	#$Area2D.monitorable = false


func sync_broadcast(client_id : int):
	if GDSync.is_gdsync_owner(self):
		
		if GameManager.is_host:
			$PropertySynchronizer.broadcast = 	0
			$PropertySynchronizer3.broadcast = 0
		else:
			$PropertySynchronizer.broadcast = 	1
			$PropertySynchronizer3.broadcast = 1
			

func charge(position : Vector2):
	#GDSync.call_func(charge,[position])
	
	global_position = position
	

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):

	called_shoot(layer, mask, dir, player, startup)
	GDSync.call_func(called_shoot,[layer, mask, dir, player, startup])

func called_shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag

	_layer = layer; _mask = mask
	set_physics_process(true)
	#$Area2D.set_monitoring(true)
	#show()
	is_visible = true
	active = true
	assign_phys_layer(layer, mask)
	my_player = player
	global_position = my_player.position
	if dir == "right":
		speed *= -1
	if player:
		player.add_lag(lag_frames)

func destroy_wraped():
	#my_player.oponent.add_lag(4)

	if my_player: 
		my_player.oponent.weak_knock = true
		my_player.dead_bullets += 1
	await  get_tree().create_timer(0.017).timeout
	deativate()

func destroy_projectile():
	
	destroy_wraped()
	#GDSync.call_func(destroy_wraped)
	
func _physics_process(delta: float) -> void:
	position.x += speed * delta
	alive_time -= delta
	
	if alive_time < 0:
		destroy_projectile()
		pass
		
func deativate():
	#$Area2D.set_collision_layer_value(_layer,false)
	#$Area2D.set_collision_mask_value(_mask,false)
	#
	active = false

	is_visible = false
	_ready()
