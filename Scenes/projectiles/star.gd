extends Projectile

var power : int = 0
@export var frame_charge_time : float =  60
var current_frame : int = 0

var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	power_multiply = dmg/(frame_charge_time/2) #max charge is 3 times stronger
	scale = Vector2(0.01,0.01)
	set_physics_process(false)
	pass # Replace with function body.


func charge(position : Vector2):
	
	current_frame += 1

	if current_frame < frame_charge_time:
		dmg += power_multiply
		scale += Vector2(0.02,0.02)
		global_position = position

func shoot(layer : int , mask : int, dir : String):
	set_physics_process(true)
	assign_phys_layer(layer, mask)
	if dir == "right":
		speed *= -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
