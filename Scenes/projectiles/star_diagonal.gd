extends Projectile
class_name StarDiagonal

var power : int = 0
@export var frame_charge_time : float =  100
var current_frame : int = 0

var power_multiply : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	GDSync.expose_node(self)
	set_physics_process(false)
	hide()



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
		player.add_lag(current_frame*0.7)
	GDSync.call_func(shoot, [layer,mask,dir,player])


func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	alive_time -= delta
	
	if alive_time < 0:
		queue_free()
		
	position.x += (speed*1.5) * delta
	position.y += speedY * delta


func destroy_projectile():
	#my_player.oponent.add_lag(4)
	GDSync.call_func(destroy_projectile)
	if my_player :my_player.oponent.weak_knock = true
	await  get_tree().create_timer(0.017).timeout
	queue_free()
	
func _on_area_2d_area_entered(area: Area2D) -> void:

	
	if area.is_in_group("projectile"):
		collide_with_projectile(area)

func online_synch(player_num : int):
	
	await  instanciated
	
	if player_num == 1:
		property_synchronizer.broadcast = 0

		
	else: 
		property_synchronizer.broadcast = 1

		
