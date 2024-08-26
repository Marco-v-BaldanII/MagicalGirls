extends Node2D

var projectiles : Array[Projectile]
@export var delayed : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Projectile:
			projectiles.push_back(child)
			




func assign_phys_layer(layer : int, mask : int):
	for projectile in projectiles:
		projectile.assign_phys_layer(layer, mask)
	

func shoot(layer : int , mask : int, dir : String, player : Player = null, startup : int = 0):
	if startup != 0:
		player.add_lag(startup)
		await get_tree().create_timer(0.01667 * startup).timeout
	else:
		player.lag_finished.emit() #No startup lag, so start end_lag
	
	if delayed:
		get_parent().remove_child(self)
		player.add_child(self)
		global_position = player.global_position
	
	var i : int = 0
	for projectile in projectiles:
		if projectile.has_method("shoot"):
			projectile.shoot(layer,mask,dir,player)
			if delayed : 
				await get_tree().create_timer(0.35).timeout
				projectile.alive_time -= 0.35 * i
				i += 1
	

func destroy_projectile():

	for projectile in projectiles:
		projectile.destroy_projectile()

	
	
