extends CampState
class_name CampRitsu

func retreating_projectile():
	var id = randi_range(0,1)
	var not_direction : String = ""
	
	if player.direction == "right" : not_direction = "left"
	else: not_direction = "right"
	
	if id == 0:
		await get_tree().create_timer(move_timer/120.0).timeout
		player.ai_press_input("jump",40)
		await get_tree().create_timer(0.017).timeout
		player.ai_press_input("w_punch",2)
	else:
		player.ai_press_input("s_punch",2)
