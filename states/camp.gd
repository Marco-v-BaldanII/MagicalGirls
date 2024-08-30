extends State
class_name CampState

var player : Player
var attack_input : String
var move_performed : bool = false

var movement_range : int = 160
var direction_chosen : bool = true
var current_direction : String = "none"

@export var zone_distance : int = 900

var timer : float = 3.0

var shoot_amount : int
var shot_projectiles : int

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
			
	shoot_amount = randi_range(4,9)
	shot_projectiles = 0
	
	pass

var move_timer := 2.0

func physics_update(delta : float):
	
	if player.crouching : return
	player.animation_tree["parameters/conditions/crouch"] = false
	player.animation_tree["parameters/conditions/not_crouch"] = true
	player.can_move = true
	
	move_timer -= delta
	
	if move_timer <= 0:
			var retreating_projectile : int = randi_range(1,10)
			move_timer = randi_range(30,100)
	
			if player.oponent.direction == "left":
				
				var id : int = randi_range(0,5)
				if id == 0 or id == 1:
					move_timer *= 0.6 #approach for less time
					player.ai_press_input("move_left",move_timer)
					player.input_buffer.push_back("move_left")
					
					var approach_id : int = randi_range(0,2)
					if approach_id == 0: Transitioned.emit(self,"approach")
					
				else:

					player.ai_press_input("move_right",move_timer)
					player.input_buffer.push_back("move_right")

					if retreating_projectile <= 3: #30percent
						await get_tree().create_timer(move_timer/120.0).timeout
						player.ai_press_input("crouch",40)
						await get_tree().create_timer(0.017).timeout
						player.ai_press_input("s_kick",2)
					elif retreating_projectile <= 4:
						var not_direction : String =""
						if player.direction == "right": not_direction = "left"
						else: not_direction = "right"
						player.input_buffer.clear(); player.input_buffer.append_array(player.moveset["book_shield_" + not_direction])
						player.perform_move()
			else:
				
				var id : int = randi_range(0,5)
				if id == 0 or id == 1:
					move_timer *= 0.6
					player.ai_press_input("move_right",move_timer)
					player.input_buffer.push_back("move_right")
					
					var approach_id : int = randi_range(0,2)
					if approach_id == 0: Transitioned.emit(self,"approach")
				else:
					player.ai_press_input("move_left",move_timer)
					player.input_buffer.push_back("move_left")
					
					if retreating_projectile <= 3:
						await get_tree().create_timer(move_timer/120.0).timeout
						player.ai_press_input("crouch",40)
						await get_tree().create_timer(0.017).timeout
						player.ai_press_input("s_kick",2)
					elif retreating_projectile <= 4:
						var not_direction : String =""
						if player.direction == "right": not_direction = "left"
						else: not_direction = "right"
						player.input_buffer.clear(); player.input_buffer.append_array(player.moveset["book_shield_" + not_direction])
						player.perform_move()

			move_timer /= 60
	timer -= delta
	
	if timer <= 0:
		shoot_projectile()
		timer = randf_range(0.4,5.0)
	
	pass

func shoot_projectile():
	
	player.ai_press_input("s_kick",1)
	shot_projectiles += 1
	
	if shot_projectiles >= shoot_amount:
		
		Transitioned.emit(self, "approach")
	
	
	pass
