extends Node
var hadoken_input_r : Array[String] = ["crouch", "move_right", "w_punch"]
var hadoken_input_l : Array[String] = ["crouch", "move_left", "w_punch"]

var Ritsu : Dictionary = {
	
	"hadoken_right" : hadoken_input_r,
	"hadoken_left" : hadoken_input_l
	
}
var Larissa : Dictionary = {}
var Anastasia : Dictionary = {}
var Ellie : Dictionary = {}

var movesets : Dictionary = {
	"Ritsu" : Ritsu,
	"Larissa" : Larissa
}
