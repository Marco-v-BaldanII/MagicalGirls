extends Sprite2D
class_name Projectile

@export var alive_time : float = 5
@export var lag_frames : int = 20
@onready var area_2d: Area2D = $Area2D
@export var speed = 400
@export var speedY = 0

@export var dmg : float = 8

var my_player : Player
var active : bool = false

var _visible : bool = false:
	set(value):
		_visible = value
		if value:
			show()
		else:
			hide()

func _ready() -> void:

	GDSync.expose_node(self)
	set_physics_process(false)
	hide()

func _physics_process(delta: float) -> void:
	alive_time -= delta

	if alive_time < 0:
		queue_free()
		
	position.x += speed * delta
	position.y += speedY * delta

func assign_phys_layer(layer : int, mask : int):
	if not area_2d: area_2d = $Area2D
	area_2d.set_collision_layer_value(layer,true)
	if layer == 2: area_2d.set_collision_mask_value(3,true)
	else: area_2d.set_collision_mask_value(2,true)
	area_2d.set_collision_mask_value(mask,true)

var _layer = 0
var _mask = 0

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	
	called_shoot(layer, mask, dir, player, startup)
	GDSync.call_func(called_shoot,[layer, mask, dir, player, startup])

func called_shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	elif player:
		player.lag_finished.emit() #No startup lag, so start end_lag

	_layer = layer; _mask = mask
	set_physics_process(true)
	$Area2D.set_monitoring(true)
	show()
	active = true
	assign_phys_layer(layer, mask)
	my_player = player
	if player:
		global_position = my_player.position
		if dir == "right":
			speed *= -1
		if player:
			player.add_lag(lag_frames)

func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
	
func collide_with_projectile(area : Area2D):
	
	if area.has_method("get_projectile"):
		var enemy_projectile : Projectile = area.get_projectile()
		if enemy_projectile.dmg >= dmg -2:
			destroy_projectile()


func _on_area_2d_area_entered(area: Area2D) -> void:

	
	if area.is_in_group("projectile"):
		collide_with_projectile(area)


func online_synch(player_num : int):
	if player_num == 1:
		$PositionSynchronizer.broadcast = 0
		$PropertySynchronizer2.broadcast = 0
		$PropertySynchronizer3.broadcast = 0
		
		
	else: 
		$PositionSynchronizer.broadcast = 1
		$PropertySynchronizer2.broadcast = 1
		$PropertySynchronizer3.broadcast = 1
		
