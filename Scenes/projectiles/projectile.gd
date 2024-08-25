extends Sprite2D
class_name Projectile

@export var alive_time : float = 5
@export var lag_frames : int = 20
@onready var area_2d: Area2D = $Area2D
@export var speed = 400
@export var speedY = 0

@export var dmg : float = 8

var my_player : Player


func _ready() -> void:
	dmg = 2
	GDSync.expose_node(self)
	set_physics_process(false)
	hide()

func _physics_process(delta: float) -> void:
	alive_time -= delta

	if alive_time < 0:
		queue_free()
		
	position.x += speed * delta

func assign_phys_layer(layer : int, mask : int):
	if not area_2d: area_2d = $Area2D
	area_2d.set_collision_layer_value(layer,true)
	area_2d.set_collision_mask_value(mask,true)

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

	GDSync.call_func(shoot, [layer,mask,dir,player])

func destroy_projectile():
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
	
