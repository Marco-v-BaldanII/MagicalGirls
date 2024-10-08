extends State
class_name CrouchState

var player : Player

func enter():

	GDSync.expose_node(self)
	if not player:
			var e = get_parent()
			while (e == null or not ( e is  Player)):
				e = e.get_parent()
			player = e

	player.velocity.x = 0
	player.animation_tree["parameters/conditions/idle_anim"] = true
	player.animation_tree["parameters/conditions/crouch"] = true

	player.animation_tree["parameters/conditions/not_crouch"] = false
	player.animation_tree.set("parameters/playback/current", "crouching")
	player.crouching = true
	
	await  get_tree().create_timer(0.1).timeout
	



func physics_update(delta : float):
	
	if GameManager.online and   not GDSync.is_gdsync_owner(player): 
		return
	
	
	#player.animation_tree["parameters/conditions/crouch"] = true
	var joy_x = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_X)
	var joy_y = Input.get_joy_axis(player.player_id, JOY_AXIS_LEFT_Y)

	if (not player.is_mapped_action_pressed("crouch") and 
	not(joy_y ==  1 and abs(joy_x) < 0.4))  :
		if not player.ai_player:
			if player.can_move:
				transition_ground()
				GDSync.expose_func(transition_ground)
				GDSync.call_func(transition_ground)
	
	#Transition specifically for cpus
	if player.ai_player and not player.is_input_pressed("crouch"):
		transition_ground()
	

func exit():
	player.crouching = false
	player.animation_tree["parameters/conditions/crouch"] = false
	player.animation_tree["parameters/conditions/not_crouch"] = true
	player.animation_tree.set("parameters/playback/current", "idle_anim")
	

func transition_ground():
	#player.animation_tree["parameters/conditions/crouch"] = false
	#player.animation_tree["parameters/conditions/not_crouch"] = true
	Transitioned.emit(self, "ground_move")

	await  get_tree().create_timer(0.16*6).timeout
	#player.animation_tree["parameters/conditions/not_crouch"] = false
