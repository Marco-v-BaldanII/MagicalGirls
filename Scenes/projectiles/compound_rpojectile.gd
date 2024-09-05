extends Node2D

var projectiles : Array[Projectile]
@export var delayed : bool = false

@export var at_global : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if at_global:
		var parent = get_parent()
		parent.remove_child(self)
		GameManager.p2_spawns.add_child(self)
	
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
	
	if delayed and not at_global:
		get_parent().remove_child(self)
		player.add_child(self)
		global_position = player.global_position
	
	var i : int = 0
	for projectile in projectiles:
		if is_instance_valid(projectile) and projectile.has_method("shoot"):
			if not at_global : projectile.shoot(layer,mask,dir,player)
			else:  
				projectile.shoot(layer,mask,dir,null)
			if delayed : 
				await get_tree().create_timer(0.35).timeout
				if is_instance_valid(projectile):
					projectile.alive_time -= 0.35 * i
				i += 1
	

func destroy_projectile():

	for projectile in projectiles:
		projectile.destroy_projectile()
	queue_free()
	
	
