extends Node2D

var projectiles : Array[Projectile]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Projectile:
			projectiles.push_back(child)



func assign_phys_layer(layer : int, mask : int):
	for projectile in projectiles:
		projectile.assign_phys_layer(layer, mask)
	

func shoot(layer : int , mask : int, dir : String, player : Player = null):
	for projectile in projectiles:
		if projectile.has_method("shoot"):
			projectile.shoot(layer,mask,dir,player)
	

func destroy_projectile():

	for projectile in projectiles:
		projectile.destroy_projectile()

	
	
