extends State
class_name KnockedState

var player : Player

const KNOCKED_FRAMES : int = 10

const STRONG_KNOCKED_FRAMES : int = 15

const KNOCK_FORCE : int = 300

const STRONG_KNOCK_FORCE : int = 600

var knocked_time : float


func enter():
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e
	player.grounded = false
	if player.strong_knock:
		if not player.moving_backwards:
			knocked_time = 0.0166 * STRONG_KNOCKED_FRAMES
		else:
			knocked_time = 0.0166 * STRONG_KNOCKED_FRAMES/2
	else:
		if not player.moving_backwards:
			knocked_time = 0.0166 * KNOCKED_FRAMES
		else:
			knocked_time = 0.0166 *  KNOCKED_FRAMES/2

	
func physics_update(delta : float):
	
	knocked_time -= delta
	
	if player.direction == "right":
		if player.strong_knock:
			player.velocity.x = STRONG_KNOCK_FORCE
		else:
			player.velocity.x = KNOCK_FORCE
	else:
		if player.strong_knock:
			player.velocity.x = -STRONG_KNOCK_FORCE
		else:
			player.velocity.x = -KNOCK_FORCE
		
	
	if knocked_time <= 0:
		Transitioned.emit(self, "ground_move")
	
	pass
