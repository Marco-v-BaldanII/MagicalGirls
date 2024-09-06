extends Node
var hadoken_input_r : Array[String] = ["crouch", "move_right", "s_punch"]
var hadoken_input_l : Array[String] = ["crouch", "move_left", "s_punch"]

var fire_shot_r : Array[String] = ["crouch","move_left","s_punch"]
var fire_shot_l : Array[String] = ["crouch","move_right","s_punch"]

var ritsu_ulti : Array[String] = ["l_trigger", "r_trigger"]

var Ritsu : Dictionary = {
	
	"triple_shot_right" : hadoken_input_r,
	"triple_shot_right_lag" : 40,
	"triple_shot_right_startup" : 5,
	"triple_shot_right_cost" : 0,
	"triple_shot_left" : hadoken_input_l,
	"triple_shot_left_lag" : 40,
	"triple_shot_left_startup" : 5,
	"triple_shot_left_cost" : 0,
	
	"fire_shot_right" : fire_shot_r,
	"fire_shot_left" : fire_shot_l,
	"fire_shot_left_lag" : 20,
	"fire_shot_left_cost" : 200,
	"fire_shot_right_lag" : 20,
	"fire_shot_left_startup" : 18,
	"fire_shot_right_startup" : 18,
	"fire_shot_right_cost" : 200,
	
	"ritsu_ulti" : ritsu_ulti,
	"ritsu_ulti_lag" : 48,
	"ritsu_ulti_cost" : 0,
	"ritsu_ulti_startup" : 18,
	
}
var Larissa : Dictionary = {}

var anastasia_ulti : Array[String] = ["l_trigger", "r_trigger"]

var triple_bombardment_right : Array[String] = ["move_left", "move_right", "move_left", "move_right" , "s_kick"]
var triple_bombardment_left : Array[String] =  ["move_right", "move_left", "move_right" , "move_left", "s_kick"]
var power_shoot_left : Array[String] = ["crouch" , "move_left", "s_punch"]
var power_shoot_right : Array[String] = ["crouch" , "move_right", "s_punch"]

var molotov_left : Array[String] = ["crouch","move_right","s_punch"]
var molotov_right : Array[String] = ["crouch","move_left","s_punch"]

var two_kinfe_attack : Array[String] = ["move_right","w_punch"]

var Anastasia : Dictionary = {
	
	"triple_bombardment_right" : triple_bombardment_right,
	"triple_bombardment_right_startup" : 10,
	"triple_bombardment_right_lag" : 10,
	"triple_bombardment_right_cost" : 300,
	"triple_bombardment_left_cost" : 300,
	"triple_bombardment_left" : triple_bombardment_left,
	"triple_bombardment_left_startup" : 10,
	"triple_bombardment_left_lag" : 10,
	
	"power_shoot_left" : power_shoot_left,
	"power_shoot_left_lag" : 50,
	"power_shoot_left_startup" : 10,
	"power_shoot_left_cost" : 300,

	"power_shoot_right" : power_shoot_right,
	"power_shoot_right_lag" : 50,
	"power_shoot_right_startup" : 10,
	"power_shoot_right_cost" : 300,
	
	"molotov_left" : molotov_left,
	"molotov_left_lag" : 30,
	"molotov_left_startup" : 8,
	"molotov_left_cost" : 200,
	
	"molotov_right" : molotov_right,
	"molotov_right_lag" : 30,
	"molotov_right_startup" : 8,
	"molotov_right_cost" : 200,
	
	"2knife_attack" : two_kinfe_attack,
	"2knife_attack_lag" : 10,
	"2knife_attack_startup" : 5,
	"2knife_attack_cost" : 200,
	
	#"ritsu_ulti" : ritsu_ulti,
	#"ritsu_ulti_lag" : 0,
	#"ritsu_ulti_cost" : 0,
	#"ritsu_ulti_startup" : 18,
	
	"anastasia_ulti" : ritsu_ulti,
	"anastasia_ulti_lag" : 15,
	"anastasia_ulti_startup" : 0,
	"anastasia_ulti_cost" : 0
}

var shield : Array[String] = ["crouch","move_left" ,"s_kick"]
var shield_left : Array[String] = ["crouch","move_right" ,"s_kick"]

var Ellie : Dictionary = {
	
	"book_shield_right" : shield,
	"book_shield_right_lag" : 40,
	"book_shield_right_startup" : 20,
	"book_shield_right_cost" : 300,
	
	"book_shield_left" : shield_left,
	"book_shield_left_lag" : 40,
	"book_shield_left_startup" : 20,
	"book_shield_left_cost" : 300,
}

var movesets : Dictionary = {
	"Ritsu" : Ritsu,
	"Larissa" : Larissa,
	"Anastasia" : Anastasia,
	"Ellie Quinn" : Ellie
}
