extends State
class_name AtkState

var player : Player
var attack_input : String
var move_performed : bool = false

var movement_range : int = 160
var direction_chosen : bool = true
var current_direction : String = "none"

@export var atk_distance : int = 380
var chance_not_camp : int = 1

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
			
	perform_attack()
	
	pass

func exit():
	pass

#The ai should know which of their moves hit below block and if the player is blocking perform them
#also attack head when player is crouching

func physics_update(delta : float):
	
	if player.crouching: return
	
	if move_performed:
		move_performed = false
		await get_tree().create_timer(randf_range(0.3,0.8)).timeout
		perform_attack()
		var d =  abs(player.oponent.global_position.x - player.global_position.x)

	elif direction_chosen:
		direction_chosen = false
		
		await get_tree().create_timer(randf_range(0.6,1.2)).timeout
		move()
		pass
		
	if current_direction != "none" and not player.crouching:
			player.ai_press_input(current_direction,randi_range(8,16))
			

func perform_attack():
	var attack_id = randi_range(0,5)
	match attack_id:
		0:
			first_atk_option()
		1:
			second_atk_option()
		2:
			third_atk_option()
		3: 
			fourth_atk_option()
		4:
			fith_atk_option()
		5:
			sixth_atk_option()

	move_performed = true

func move() :
	if abs(player.oponent.global_position.x - player.global_position.x) > atk_distance + movement_range+1:
		Transitioned.emit(self,"approach")
	var move_id = randi_range(0,2)
	direction_chosen = true
	
	match move_id:
		0:
			current_direction = "move_left"
		1:
			current_direction = "move_right"
		2:
			current_direction = "none"
			
	var jump_rand : int = randi_range(0,1)
	
	match  jump_rand:
		0:
			if not player.crouching:  
				player.ai_press_input("jump");
				var id = randi_range(0,1)
				if id == 0: player.ai_press_input("move_left")
				else: player.ai_press_input("move_right")
				 
				var atk_id = randi_range(0,5)
				
				match atk_id:
					0:
						first_atk_option()
					1:
						second_atk_option()
					2:
						third_atk_option()
					3: 
						fourth_atk_option()
					4:
						fith_atk_option()
					5:
						sixth_atk_option()

		1:
			if not player.crouching : player.ai_press_input("jump")
			
	
	
	if "move_" + player.direction == current_direction:
		var camp_id = randi_range(0,chance_not_camp)
		if camp_id == 0: 
			Transitioned.emit(self, "camp")
	
	pass



func first_atk_option():
	player.ai_press_input("s_punch")
	
func second_atk_option():
	player.ai_press_input("w_punch")
	
func third_atk_option():
	player.ai_press_input("w_kick")
	
func fourth_atk_option():
	player.ai_press_input("s_kick")
	
func fith_atk_option():
	player.ai_press_input("crouch",70)

func sixth_atk_option():
	var specials = player.choose_random_special()
	var special = specials.pick_random()
	
	player.input_buffer.append_array(player.moveset[special])
	player.perform_move()
