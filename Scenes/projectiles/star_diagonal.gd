extends Projectile
class_name Star

var power : int = 0
@export var frame_charge_time : float =  100
var current_frame : int = 0

var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_node(self)



func shoot(layer : int , mask : int, dir : String, player : Player = null):
	set_physics_process(true)
	assign_phys_layer(layer, mask)
	if dir == "right":
		speed *= -1
	if player:
		player.add_lag(current_frame*0.7)
	GDSync.call_func(shoot, [layer,mask,dir,player])


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	alive_time -= delta
	
	if alive_time < 0:
		queue_free()
		
	position.x += (speed*1.5) * delta
	position.y += abs(speed * delta)
