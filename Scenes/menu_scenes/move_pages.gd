extends Node2D

var pages : Array[Control]

var index : int = 0

var right_pos : Vector2 = Vector2(1940 , 0)
var left_pos : Vector2 = Vector2(-1940 ,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if not child is TextureRect:
			pages.push_back(child as Control)

var can_turn : bool = true

func _process(delta: float) -> void:
	
	if Pause.active and can_turn:
		
		if Controls.is_ui_action_pressed("r_trigger"):
			index -= 1
			pass_page("left")
		elif Controls.is_ui_action_pressed("l_trigger"):
			index += 1
			pass_page("right")
		
		elif Controls.is_joy_button_just_pressed("go_back"):
			$"../Node2D".activate()
			hide()
		
func pass_page(dir : String):
	
	if dir == "right":
		pages[(index) % pages.size()].position = left_pos

		var tween = create_tween()
		tween.tween_property(pages[(index -1) % pages.size()], "position", right_pos,0.4) #move previous page right
		tween.set_ease(Tween.EASE_IN_OUT); tween.set_trans(Tween.TRANS_ELASTIC)

		
		var tween2 = create_tween()
		tween2.tween_property(pages[(index) % pages.size()], "position", Vector2(0,0),0.4) #mov current page to center
		
		tween2.set_ease(Tween.EASE_IN_OUT); tween2.set_trans(Tween.TRANS_ELASTIC)

		can_turn = false
		await  tween2.finished
		can_turn = true
		
	elif dir == "left":
		pages[(index) % pages.size()].position = right_pos
		
		var tween = create_tween()
		tween.tween_property(pages[(index + 1) % pages.size()], "position", left_pos,0.4) #move previous page right
		tween.set_ease(Tween.EASE_IN_OUT); tween.set_trans(Tween.TRANS_ELASTIC)

		
		var tween2 : = create_tween()
		tween2.tween_property(pages[(index) % pages.size()], "position", Vector2(0,0),0.4) #mov current page to center
		
		tween2.set_ease(Tween.EASE_IN_OUT); tween.set_trans(Tween.TRANS_ELASTIC)

		can_turn = false
		await  tween2.finished
		can_turn = true
