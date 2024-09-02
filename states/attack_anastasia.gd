extends AtkState
class_name AttackAnastasia

func first_atk_option():
	player.ai_press_input("s_punch", randi_range(2*20,5*20))
	
func second_atk_option():
	player.ai_press_input("w_punch")
	
func third_atk_option():
	player.ai_press_input("w_kick")
	
func fourth_atk_option():
	var specials = player.choose_random_special()
	var special = specials.pick_random()
	
	player.input_buffer.append_array(player.moveset[special])
	player.perform_move()
	
func fith_atk_option():
	player.ai_press_input("crouch",70)

func sixth_atk_option():
	var specials = player.choose_random_special()
	var special = specials.pick_random()
	
	if special == null: return
	
	player.input_buffer.append_array(player.moveset[special])
	player.perform_move()
