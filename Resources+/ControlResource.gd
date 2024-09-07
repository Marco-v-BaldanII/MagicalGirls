extends Resource
class_name ControlSource

@export var my_name : String

@export var controls : Dictionary = {
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
