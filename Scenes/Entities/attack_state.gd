extends State

var player : AI_Player
var attack_input : String
var move_performed : bool = false

var movement_range : int = 160
var direction_chosen : bool = true
var current_direction : String = "none"

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
		await get_tree().create_timer(2).timeout
		perform_attack()
		var d =  abs(player.oponent.global_position.x - player.global_position.x)

	elif direction_chosen:
		direction_chosen = false
		
		await get_tree().create_timer(randf_range(0.6,1.2)).timeout
		move()
		pass
		
	if current_direction != "none" and not player.crouching:
			player.press_input(current_direction,10)
			

func perform_attack():
	var attack_id = randi_range(0,4)
	match attack_id:
		0:
			attack_input = "s_punch"
		1:
			attack_input = "w_punch"
		2:
			attack_input = "s_kick"
		3: 
			attack_input = "w_kick"
		4:
			attack_input = "crouch"
	if attack_id == 4 :player.press_input(attack_input,100)
	else: player.press_input(attack_input)
	move_performed = true

func move() :
	if abs(player.oponent.global_position.x - player.global_position.x) > player.attack_distance + movement_range+1:
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
				player.press_input("jump"); 
				var atk_id = randi_range(0,3)
				
				match atk_id:
					0:
						attack_input = "s_punch"
					1:
						attack_input = "w_punch"
					2:
						attack_input = "s_kick"
					3: 
						attack_input = "w_kick"
						
		1:
			if not player.crouching : player.press_input("jump")
			return
	
	pass
