extends State

var player : AI_Player
var attack_input : String
var move_performed : bool = false

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
	
	if move_performed:
		move_performed = false
		await get_tree().create_timer(2).timeout
		perform_attack()
		var d =  abs(player.oponent.global_position.x - player.global_position.x)
		if abs(player.oponent.global_position.x - player.global_position.x) > player.attack_distance:
			Transitioned.emit(self,"approach")


func perform_attack():
	var attack_id = randi_range(0,3)
	match attack_id:
		0:
			attack_input = "s_punch"
		1:
			attack_input = "w_punch"
		2:
			attack_input = "s_kick"
		3: 
			attack_input = "w_kick"
			
	player.press_input(attack_input)
	move_performed = true
