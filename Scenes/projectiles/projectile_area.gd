extends Area2D
@onready var star : Projectile = $".."


func get_dmg() -> int:
	return floori( $"..".dmg) 
	
func get_projectile() ->Projectile:
	return $".."
