extends Node
var hadoken_input_r : Array[String] = ["crouch", "move_right", "w_punch"]
var hadoken_input_l : Array[String] = ["crouch", "move_left", "w_punch"]

var Ritsu : Dictionary = {
	
	"triple_shot_right" : hadoken_input_r,
	"triple_shot_right_lag" : 40,
	"triple_shot_left" : hadoken_input_l,
	"triple_shot_left_lag" : 40
	
}
var Larissa : Dictionary = {}
var Anastasia : Dictionary = {}
var Ellie : Dictionary = {}

var movesets : Dictionary = {
	"Ritsu" : Ritsu,
	"Larissa" : Larissa
}
