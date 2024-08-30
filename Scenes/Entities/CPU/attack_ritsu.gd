extends AtkState
class_name AtkRitsu

func first_atk_option():
	player.ai_press_input("s_punch")
	
func second_atk_option():
	player.ai_press_input("w_punch")
	
func third_atk_option():
	player.ai_press_input("w_kick")
	
func fourth_atk_option():
	player.ai_press_input("s_kick")
	
func fith_atk_option():
	player.ai_press_input("jump",70)
	
	var id : int = randi_range(1,4)
	match id:
			1:first_atk_option()
			2: second_atk_option()
			3: third_atk_option()
			4: fourth_atk_option()

func sixth_atk_option():
	var specials = player.choose_random_special()
	var special = specials.pick_random()
	
	player.input_buffer.append_array(player.moveset[special])
	player.perform_move()
