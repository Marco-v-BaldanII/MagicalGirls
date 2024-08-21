extends State
class_name KnockedState

var player : Player

const KNOCKED_FRAMES : int = 10

const STRONG_KNOCKED_FRAMES : int = 18

const WEAK_KNOCK_FRAMES : int = 1

const KNOCK_FORCE : int = 300

const STRONG_KNOCK_FORCE : int = 800

const WEAK_KNOCK_FORCE : int = 20

var knocked_time : float


var launch_forceY : int = 1200
var launch_forceX : int = 350
var speedY = launch_forceY
var gravity = 30

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
	elif player.weak_knock:
		if not player.moving_backwards:
			knocked_time = 0.0166 * WEAK_KNOCK_FRAMES
		else:
			knocked_time = 0.0166 * WEAK_KNOCK_FRAMES/2
	else:
		if not player.moving_backwards:
			knocked_time = 0.0166 * KNOCKED_FRAMES
		else:
			knocked_time = 0.0166 *  KNOCKED_FRAMES/2
			
	

var lauched_to_ground : bool = false

func physics_update(delta : float):
	
	knocked_time -= delta
	player.lag = true
	
	if not player.launch_knock:
		if player.direction == "right":
			if player.strong_knock and not lauched_to_ground:
				player.velocity.x = STRONG_KNOCK_FORCE
			else:
				player.velocity.x = KNOCK_FORCE
		else:
			if player.strong_knock and not lauched_to_ground:
				player.velocity.x = -STRONG_KNOCK_FORCE
			else:
				player.velocity.x = -KNOCK_FORCE
			
		
	print("vertical v " + str(player.velocity.y))
	if player.launch_knock and not lauched_to_ground:
		player.position.y -= speedY * delta
		if player.direction == "right":
				player.velocity.x = KNOCK_FORCE
		else:
				player.velocity.x = -KNOCK_FORCE
		speedY -= gravity
	
	if  (player.launch_knock and player.is_on_floor() and speedY < 0):
		
		if player.launch_knock and not lauched_to_ground:
			speedY = launch_forceY
			#player.animation_tree["parameters/conditions/fallen"] = true
			player.sprite_2d.rotation = -180
			lauched_to_ground = true

			await get_tree().create_timer(0.01667 *12).timeout
			player.sprite_2d.rotation = 0
			lauched_to_ground = false
		
		player.weak_knock = false; player.lag= false;
		Transitioned.emit(self, "ground_move")
		
	if knocked_time < 0 and not player.launch_knock:
		player.weak_knock = false; player.lag= false;
		Transitioned.emit(self, "ground_move")
	
	pass
