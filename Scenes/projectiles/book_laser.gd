extends Projectile
class_name Book_Laser

var power : int = 0
@export var frame_charge_time : float =  185
var current_frame : int = 0

var power_multiply : float

var fully_charged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GDSync.expose_node(self)
	dmg = 4
	area_2d.monitorable = false; area_2d.monitoring = false;
	power_multiply = dmg/(frame_charge_time/4) #max charge is 3 times stronger
	scale = Vector2(0.2,0.2)
	set_physics_process(false)
	pass # Replace with function body.

var stage : int = 1

func charge(position : Vector2):
	#GDSync.call_func(charge,[position])
	hide()
	global_position = position
	
	if current_frame < frame_charge_time:
		current_frame += 1
		if current_frame > (frame_charge_time/3) * stage:
			stage += 1
			dmg *= 2
			speed -= 300
			scale += Vector2(0.2,0.2)
		
		#dmg += power_multiply
		#scale += Vector2(0.005,0.005)
	elif not current_frame < frame_charge_time:
		fully_charged = true

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
	GDSync.call_func(assign_phys_layer,[layer,mask])
	show()
	
	area_2d.monitorable = true; area_2d.monitoring = true;
	
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

	if current_frame < 20 and my_player: my_player.oponent.weak_knock = true
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
func deactivate():
	hide()
	area_2d.monitorable = false; area_2d.monitoring = false;


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("projectile"):
		collide_with_projectile(area)
	else:
		pass # Replace with function body.
