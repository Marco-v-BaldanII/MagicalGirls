extends Player
class_name AI_Player
#
#@export var attack_distance : int = 380

func _ready() -> void:
	super()
	ai_player = true
	pass



	pass

#
#func _on_hurt_box_area_entered(area: Area2D) -> void:
#
	#super(area)
	#on_hit()

#func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	##super(anim_name)
	#
	#return
	#if anim_name == "crouch":
		#
		#state_machine.on_child_transition(state_machine.current_state, "ground_move")
		#
		#pass
