extends Node 

static var cutscene: bool 
@export var game_speed : int = 1
@export var load_data : bool = true
@export var starting_scene : PackedScene

var current_scene : PackedScene
var saved_scene : String = "none"

#@onready var savestate = $Savestate

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var balloon = get_tree().get_first_node_in_group("balloon")
	if balloon != null:
		cutscene = true
	pass # Replace with function body.

func change_scene(new_scene : PackedScene ):
	SceneManager.change_scene(new_scene )
	
	current_scene = new_scene
	
func change_scene_path(path : String):
	var scene : PackedScene = load(path)
	SceneManager.change_scene(path)

	current_scene = scene
	
func save_current_scene():
	saved_scene = current_scene.resource_path
