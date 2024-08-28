extends ColorRect
class_name InputMapBox

@export var my_action : String
@onready var button_texture : TextureRect = $TextureRect
var res : ControllerIconTexture

@export var mapped_action : String
@onready var re_maper : CanvasLayer = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await  get_tree().create_timer(0.017).timeout
	re_map(my_action)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	button_texture.texture = res
	pass

func re_map(action : String):
	#res = ControllerIconTexture.new()
	#if action == "s_kick":
		#my_action = "s_punch" 
		#Controls.p1[mapped_action] = 1 #circle button id
	#elif action == "s_punch":
		#my_action = "w_punch"
		#Controls.p1[mapped_action] = 3
	#elif action == "w_punch" : 
		#my_action = "w_kick"
		#Controls.p1[mapped_action] = 2
	#elif action == "w_kick" : 
		#my_action = "s_kick"
		#Controls.p1[mapped_action] = 0
	#res.path = my_action
	#button_texture.texture = res
	res = ControllerIconTexture.new()
	if action == "s_kick":
		my_action = "s_punch" 
		re_maper.current_controls.controls[mapped_action][0] = 1 #circle button id
		re_maper.current_controls.controls[mapped_action][1] = KEY_I #circle button id
	elif action == "s_punch":
		my_action = "w_punch"
		re_maper.current_controls.controls[mapped_action][0] = 3
		re_maper.current_controls.controls[mapped_action][1] = KEY_U
	elif action == "w_punch" : 
		my_action = "w_kick"
		re_maper.current_controls.controls[mapped_action][0] = 2
		re_maper.current_controls.controls[mapped_action][1] = KEY_J
	elif action == "w_kick" : 
		my_action = "s_kick"
		re_maper.current_controls.controls[mapped_action][0] = 0
		re_maper.current_controls.controls[mapped_action][0] = KEY_K
	res.path = action
	button_texture.texture = res
	
	
