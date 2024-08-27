extends Projectile
class_name Grenade

var power_multiply : float
var explode_timer : float = 3.0
@onready var animation_tree: AnimationTree = $AnimationTree

var og_speedY : int
var og_speedX : int
var num_bounce = 2

@export var gravity = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	

	GDSync.expose_node(self)
	dmg = 10

	set_physics_process(false)
	await get_tree().create_timer(0.01667).timeout
	
	if GDSync.is_gdsync_owner(self):
		
		if GDSync.is_host():
			$PropertySynchronizer.broadcast = 	0
		else:
			$PropertySynchronizer.broadcast = 	1
	
	pass # Replace with function body.


func charge(_position : Vector2):
	#GDSync.call_func(charge,[position])
	alive_time -= 0.01667
	global_position = _position
	if alive_time < 0:
		assign_phys_layer(2,5)
		assign_phys_layer(3,4)
		animation_tree["parameters/conditions/explode"] = true
		GDSync.call_func(change_animation,["explode"])
		
	pass
		

func change_animation(anim):
	animation_tree["parameters/conditions/" + anim] = true

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
	#GDSync.call_func(assign_phys_layer,[layer,mask])
	set_physics_process(true)
	#assign_phys_layer(layer, mask)
	my_player = player
	if dir == "right":
		speed *= -1
	else:
		og_speedX *= -1
		
	og_speedY = speedY; og_speedX = speed
	if player:
		player.add_lag(lag_frames)

func destroy_projectile():
	#my_player.oponent.add_lag(4)

	if my_player: my_player.oponent.weak_knock = true
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
	
func _process(delta: float) -> void:
	alive_time -= delta

	if alive_time < 0:
		animation_tree["parameters/conditions/explode"] = true
		GDSync.call_func(change_animation,["explode"])
		GDSync.call_func(assign_phys_layer,[3,4])
		GDSync.call_func(assign_phys_layer,[2,5])
		assign_phys_layer(2,5)
		assign_phys_layer(3,4)
		
	
func _physics_process(delta: float) -> void:
	
	alive_time -= delta
		
	position.x += speed * delta
	position.y += speedY * delta
	speedY += 15
	#fall faster
	if speedY > 0:speedY += 20


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	GDSync.call_func(destroy)
	destroy()
	pass # Replace with function body.

var can_bounce : bool = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if can_bounce:
		speed *= -0.6
		og_speedX *= -0.6


func _on_area_2d_body_entered(body: Node2D) -> void:
	speedY = og_speedY*1.5/num_bounce
	speed = og_speedX*1.5/num_bounce
	speedY = clamp(speedY, -1000,-200)
	num_bounce += 1
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	can_bounce = true
	pass # Replace with function body.
"res://Scenes/projectiles/grenade.tscn"

func destroy():
	queue_free()
