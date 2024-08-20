extends Projectile
class_name Star

var my_player : Player

var power : int = 0
@export var frame_charge_time : float =  100
var current_frame : int = 0

var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_node(self)
	dmg = 4
	speed = 800
	power_multiply = dmg/(frame_charge_time/4) #max charge is 3 times stronger
	scale = Vector2(0.2,0.2)
	set_physics_process(false)
	pass # Replace with function body.


func charge(position : Vector2):
	#GDSync.call_func(charge,[position])
	
	global_position = position
	
	if current_frame < frame_charge_time:
		current_frame += 1
		dmg += power_multiply
		scale += Vector2(0.005,0.005)
		

func shoot(layer : int , mask : int, dir : String, player : Player = null):
	
	set_physics_process(true)
	assign_phys_layer(layer, mask)
	my_player = player
	if dir == "right":
		speed *= -1
	if player:
		var lag = current_frame*0.7
		player.add_lag(clamp(lag,30,50))

func destroy_projectile():
	#my_player.oponent.add_lag(4)
	GDSync.call_func(destroy_projectile)
	if current_frame < 20 and my_player: my_player.oponent.weak_knock = true
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
