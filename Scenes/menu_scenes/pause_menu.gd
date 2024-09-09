extends Node2D
class_name PauseMenu

@onready var cursor = $cursor2
@onready var grid_container = $GridContainer
@export var cursor_offset : int = 5
@export var timer : float = 0.1 

var options : Array;

var num_options : int
var current_player : Player
var current_option 



var _index: int = 0
@export var _is_active : bool = false


enum axis{
	X,
	Y,
}

@export var my_axis : axis = axis.Y

func is_descendant_of(node: Node, potential_ancestor: Node) -> bool:
	
	return potential_ancestor.is_ancestor_of(node)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _is_active:
		deactivate()
	var opt = grid_container.get_children()
	
	for i in opt:
		if i is Control:
				options.append(i)
		
	num_options = options.size()
	if num_options > 0:
		current_option = options[0]
		await get_tree().create_timer(0.2).timeout
		_change_cursor_pos()
	

func _process(delta: float) -> void:
	
	timer -= delta
	
	if options.size() > 0  and grid_container.visible and _is_active :
			if timer <= 0:
				if Controls.is_ui_action_pressed("move_down"):
					_index += 1
					while options[_index % options.size()].is_visible_in_tree() == false:
						_index += 1
					_change_cursor_pos()
					
						
				if Controls.is_ui_action_pressed("move_up"):
					_index -= 1
					while options[_index % options.size()].is_visible_in_tree() == false:
						_index -= 1
					_change_cursor_pos()
			
			if Controls.is_ui_action_pressed("accept") and current_option != null:
				
				while Controls.is_ui_action_pressed("accept"):
					await get_tree().create_timer(0.017,true,false,true).timeout
				await get_tree().create_timer(0.017*10,true,false,true).timeout
				if current_option is Option:
					var  done : bool = current_option.execute_option()
					if done:
						deactivate()
				elif current_option is Button:
					#Programatically press button
					current_option.pressed.emit()
					current_option.button_down.emit()


func _change_cursor_pos():
	
	timer = 0.15
	
	num_options = options.size()
	if my_axis == axis.X:
		cursor.global_position.x = options[_index % num_options].global_position.x + cursor_offset
		current_option = options[_index % num_options]
	else:

		cursor.global_position.y = options[_index % num_options].global_position.y + cursor_offset
		current_option = options[_index % num_options]
		

func activate():
	
	#current_player.tile_selector.deactivate()
	_is_active = true
	show()
	print("activate")

func deactivate():
	#current_player.tile_selector.activate()
	print("Deactivate")
	_is_active = false
	hide()
