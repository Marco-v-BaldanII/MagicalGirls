extends CampState
class_name CampAnastasia

func retreating_projectile():
	
	var jump_id : int = randi_range(0,4)
	
	if jump_id == 0:
		player.ai_press_input("jump",40)
		player.ai_press_input("move" + player.direction,40)
	
	
	var id : int = randi_range(0,2)
	
	if id == 0:
		await get_tree().create_timer(move_timer/120.0).timeout
		player.ai_press_input("crouch",40)
		await get_tree().create_timer(0.017).timeout
		player.ai_press_input(retreat_atk,2)
	elif id == 1:
		player.ai_press_input("s_punch",randi_range(2*20, 5*20))
	else:
		player.ai_press_input("w_punch",randi_range(2*20, 5*20))
