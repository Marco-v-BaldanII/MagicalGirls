extends Projectile
class_name FireShot

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	my_player.oponent.add_lag(45)
	
	pass # Replace with function body.
