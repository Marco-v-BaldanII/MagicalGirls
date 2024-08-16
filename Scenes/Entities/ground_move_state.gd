extends State
class_name GroundMoveState

var player : Player

func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e


func physics_update(delta : float):
	var _direction : int = 0
	if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_right"]):
		_direction += 1
	if Input.is_joy_button_pressed(player.player_id, Controls.mapping[player.player_id]["move_left"]):
		_direction -= 1
	if _direction and player.is_on_floor():
		player.jump_lag -= delta
		if(_direction > 0 and player.direction == "left") or (_direction < 0 and player.direction == "right"):
			player.velocity.x = _direction * player.SPEED
		else:
			#move slower in your back direction
			player.velocity.x = _direction * (player.SPEED*0.7)

	elif player.is_on_floor():
		player.jump_lag -= delta
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	else:
		player.grounded = false
		Transitioned.emit(self, "air_move")
	
	
	#Transition to jump
	if player.input_buffer.has("jump") and player.is_on_floor() and player.jump_lag <= 0:
		Transitioned.emit(self, "air_move")
