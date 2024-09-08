extends Node


var p1 : Dictionary = {
	"move_left" : [13, KEY_A],
	"move_right" : [14, KEY_D],
	"crouch" : [12, KEY_S],
	"jump" : [11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I],
	"l_trigger" : [9,KEY_SPACE],
	"r_trigger" : [10,KEY_SPACE],
}
var p2 : Dictionary = {
	"move_left" : [13, KEY_A],
	"move_right" : [14, KEY_D],
	"crouch" : [12, KEY_S],
	"jump" : [11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I],
	"l_trigger" : [9,KEY_SPACE],
	"r_trigger" : [10,KEY_SPACE],
}

var default : Dictionary = {
	"move_left" : [13, KEY_A],
	"move_right" : [14, KEY_D],
	"crouch" : [12, KEY_S],
	"jump" : [11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I],
	"l_trigger" : [9,KEY_SPACE],
	"r_trigger" : [10,KEY_SPACE],
}

var mapping : Dictionary = {
	0 : p1,
	1 : p2
}

var ui: Dictionary = {
	"move_left" : [13, KEY_A],
	"move_right" : [14, KEY_D],
	"move_up" : [11, KEY_W],
	"move_down" :[12, KEY_S],
	"accept" : [0, KEY_K, KEY_SPACE, KEY_ENTER],
	"go_back" : [1, KEY_I, KEY_ESCAPE, KEY_BACKSPACE],
	"crouch" : [12, KEY_S],
	"jump" :[11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I],
	"start" : [6,KEY_R],
	"select" : [4, KEY_T],
	"l_trigger" : [9,KEY_A],
	"r_trigger" : [10,KEY_D],
}
signal changed_controllers

var connected_controllers : int = 0:
	get():
		connected_controllers = Input.get_connected_joypads().size()
		return connected_controllers

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"move_down" : false,
	"move_up" : false,
	"w_punch" : false,
	"s_punch" : false,
	"w_kick" : false,
	"s_kick" : false,
	"accept" : false,
	"go_back" : false,
	"start" : false,
	"l_trigger" : false,
	"r_trigger" : false
}

func is_ui_action_pressed(action : String)-> bool:
	if Input.is_joy_button_pressed(0,ui[action][0]) :
		return true
	else:
		var i : int = 1
		while i < ui[action].size():
			if  Input.is_physical_key_pressed(ui[action][i]) :
				return true
			i += 1
	var joy_y := Input.get_joy_axis(0,JOY_AXIS_LEFT_Y);var joy_x := Input.get_joy_axis(0,JOY_AXIS_LEFT_X)
	if action == "move_up" and joy_y < -0.5:
		return true
	if action == "move_down" and joy_y > 0.5:
		return true
	if action == "move_left" and joy_x < -0.5:
		return true
	if action == "move_right" and joy_x > 0.5:
		return true

	return false


func is_joy_button_just_pressed(action_name : String):
	if action_state[action_name] == false and is_ui_action_pressed(action_name):
		action_state[action_name] = true
		return true
	if not is_ui_action_pressed(action_name) :
		action_state[action_name] = false
	return false

func _ready() -> void:
	connected_controllers = Input.get_connected_joypads().size()
	Input.joy_connection_changed.connect(change_controllers)
	
func change_controllers(device: int, connected: bool):
	connected_controllers = Input.get_connected_joypads().size()
	changed_controllers.emit()

func controller_rumble():
	Input.start_joy_vibration(1,1,1,2)
	
	
