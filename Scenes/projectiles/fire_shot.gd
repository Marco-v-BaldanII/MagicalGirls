extends Projectile
class_name FireShot

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.is_in_group("projectile"):
		collide_with_projectile(area)
	else:
		my_player.oponent.add_lag(45)
	
	pass # Replace with function body.
