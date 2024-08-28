extends Node


var p1 : Dictionary = {
	"move_left" : 13,
	"move_right" : 14,
	"crouch" : 12,
	"jump" : 11,
	"w_punch" : 2,
	"s_punch" : 3,
	"w_kick" : 0,
	"s_kick" : 1
}
var p2 : Dictionary = {
	"move_left" : 13,
	"move_right" : 14,
	"crouch" : 12,
	"jump" : 11,
	"w_punch" : 2,
	"s_punch" : 3,
	"w_kick" : 0,
	"s_kick" : 1
}

var default : Dictionary = {
	"move_left" : [13, KEY_A],
	"move_right" : [14, KEY_D],
	"crouch" : [12, KEY_S],
	"jump" : [11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I]
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
	"accept" : [0, KEY_K],
	"go_back" : [1, KEY_I],
	"crouch" : [12, KEY_S],
	"jump" :[11, KEY_W],
	"w_punch" : [2, KEY_J],
	"s_punch" : [3, KEY_U],
	"w_kick" : [0, KEY_K],
	"s_kick" : [1, KEY_I]
}
