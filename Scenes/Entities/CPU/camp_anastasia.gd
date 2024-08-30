extends CampState
class_name CampAnastasia

func retreating_projectile():
	
	var id : int = randi_range(0,1)
	
	if id == 0:
		await get_tree().create_timer(move_timer/120.0).timeout
		player.ai_press_input("crouch",40)
		await get_tree().create_timer(0.017).timeout
		player.ai_press_input(retreat_atk,2)
	else:
		player.ai_press_input("s_punch",randi_range(4*20, 8*20))
