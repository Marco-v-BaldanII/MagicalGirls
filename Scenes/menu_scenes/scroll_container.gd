extends ScrollContainer

class_name ScrollMenu

@onready var cursor = $"../cursor"
@onready var grid_container = $ControlerMenu1
@export var menu_button : String
@export var cursor_offset : int = 5
var options : Array;

var num_options : int = 0
var current_option 



var _index: int = 0
@export var _is_active : bool = true

@export_category("Scrollabel Control")
@export var num_of_options_fit  : int = 4
@export var scroll_offset : int = 23
var num_scrolled_down : int = 0

var marker_down : int = 0


enum axis{
	X,
	Y,
}

@export var my_axis : axis = axis.Y

signal option_selected

func is_descendant_of(node: Node, potential_ancestor: Node) -> bool:
	
	return potential_ancestor.is_ancestor_of(node)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _is_active:
		deactivate()
	var opt = grid_container.get_children()
	
	for i in opt:
		if i is Option or i is Button or i is ColorRect:
				options.append(i)
		
	num_options = options.size()
	if num_options > 0:
		current_option = options[0]
		await get_tree().create_timer(0.2).timeout
		_change_cursor_pos()
	
func activate():
	cursor.show()
	show()
	_is_active = true

	print("activate")

func deactivate():


	hide()
	print("Deactivate")
	_is_active = false
	cursor.hide()

func _input(event):

		if _is_active and options.size() > 0:
			
			for i in options.size():
				if options[i] == null:
					options.remove_at(i)
					break

			if Input.is_action_just_pressed("crouch") :
				_index += 1
				if _index % options.size() == 0:
					_index = 0
					scroll_vertical = 0
					marker_down = -1

				if _index > num_of_options_fit-1 and _index > marker_down:
					scroll_vertical += scroll_offset
					marker_down = _index
				await get_tree().create_timer(0.017).timeout
				_change_cursor_pos()
					
			if Input.is_action_just_pressed("jump"):
				_index -= 1
				if _index < 0:
					_index = num_options-1
					marker_down = num_options-1
					scroll_vertical = scroll_offset * (num_options - num_of_options_fit)

				
				elif abs(_index - marker_down) >= num_of_options_fit:
					scroll_vertical -= scroll_offset
					marker_down -= 1
				await get_tree().create_timer(0.017).timeout
				_change_cursor_pos()
				
			if Input.is_action_just_pressed("accept") and current_option != null:
				
				var control_resource : ControlSource = load("res://ControlSchemes/"+current_option.label.text+".tres")
				Controls.p1 = control_resource.controls.duplicate()
				Controls.mapping[0] = Controls.p1
				
				#current_option.execute_option()
				option_selected.emit()
			




func _change_cursor_pos():
	pass
	num_options = options.size()
	#print(_index)
	if my_axis == axis.X:
		cursor.global_position.x = options[_index % num_options].global_position.x + cursor_offset
		current_option = options[_index % num_options]
	else:
		print(scroll_vertical)
		var v = options[_index % num_options].global_position.y
		cursor.global_position.y = options[_index % num_options].global_position.y + cursor_offset + 0
		current_option = options[_index % num_options]
		
		


func recount_options():
	options.clear()
	var opt = grid_container.get_children()
	for i in opt:
		if i is Option or i is Button or i is ColorRect:
				options.append(i)
		
	num_options = options.size()


func _on_button_button_down() -> void:
	if not _is_active:
		activate()
	else:
		deactivate()
	pass # Replace with function body.
