extends Area2D
@onready var star : Projectile = $".."


func get_dmg() -> int:
	return floori(star.dmg) 
	
func get_projectile() ->Projectile:
	return star
