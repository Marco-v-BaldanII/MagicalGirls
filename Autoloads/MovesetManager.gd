extends Node
var hadoken_input_r : Array[String] = ["crouch", "move_right", "s_punch"]
var hadoken_input_l : Array[String] = ["crouch", "move_left", "s_punch"]

var fire_shot_r : Array[String] = ["crouch","move_left","s_punch"]
var fire_shot_l : Array[String] = ["crouch","move_right","s_punch"]

var Ritsu : Dictionary = {
	
	"triple_shot_right" : hadoken_input_r,
	"triple_shot_right_lag" : 40,
	"triple_shot_right_startup" : 5,
	"triple_shot_left" : hadoken_input_l,
	"triple_shot_left_lag" : 40,
	"triple_shot_left_startup" : 5,
	
	"fire_shot_right" : fire_shot_r,
	"fire_shot_left" : fire_shot_l,
	"fire_shot_left_lag" : 20,
	"fire_shot_right_lag" : 20,
	"fire_shot_left_startup" : 18,
	"fire_shot_right_startup" : 18,
	
}
var Larissa : Dictionary = {}
var Anastasia : Dictionary = {}
var Ellie : Dictionary = {}

var movesets : Dictionary = {
	"Ritsu" : Ritsu,
	"Larissa" : Larissa
}
