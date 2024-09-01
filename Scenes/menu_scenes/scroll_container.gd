extends ScrollContainer

class_name ScrollMenu

@onready var cursor = $"../cursor"
@onready var grid_container = $ControlerMenu1
@export var menu_button : String
@export var cursor_offset : int = 5
var options : Array;

var num_options : int = 0
var current_option 

@export var player_id : int

var _index: int = 0
@export var _is_active : bool = true

@export_category("Scrollabel Control")
@export var num_of_options_fit  : int = 4
@export var scroll_offset : int = 23
var num_scrolled_down : int = 0

var marker_down : int = 0

@export var controller_menu : bool = true

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
		
	Controls.changed_controllers.connect(change_in_controllers)
	change_in_controllers()


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
		
		if is_joy_button_just_pressed("start"):
			if _is_active: deactivate()
			else: activate()
		

		if _is_active and options.size() > 0:
			
			for i in options.size():
				if options[i] == null:
					options.remove_at(i)
					break

			if is_joy_button_just_pressed("move_down") :
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
					
			if is_joy_button_just_pressed("move_up"):
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
				
			if is_joy_button_just_pressed("accept") and current_option != null:
					if current_option is ControlerOption:
						
						var control_resource : ControlSource = load("res://ControlSchemes/"+current_option.label.text+".tres")
						if player_id == 0:
							Controls.p1 = control_resource.controls.duplicate()
							Controls.mapping[0] = Controls.p1
						else:
							Controls.p2 = control_resource.controls.duplicate()
							Controls.mapping[1] = Controls.p2
						
						#current_option.execute_option()
						option_selected.emit()
						$"../tag_panel/tag_label".text = current_option.label.text
						deactivate()
						
					else:
						current_option.execute_option()
		if is_joy_button_just_pressed("go_back"):

				while  Input.is_joy_button_pressed(0,Controls.ui["go_back"][0]) or  Input.is_physical_key_pressed(Controls.ui["go_back"][1]):
					await get_tree().create_timer(0.017).timeout
				#wait for the  input to not be pressed
				_on_go_back_pressed()

				




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

enum INPUT_METHOD{
	CONTROLLER_1,
	CONTROLLER_2,
	KEYBOARD
}

var input_method : INPUT_METHOD = INPUT_METHOD.KEYBOARD

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"move_down" : false,
	"move_up" : false,
	"accept" : false,
	"go_back" : false,
	"start" : false

}

func is_joy_button_just_pressed(action_name : String) -> bool:
	if input_method != INPUT_METHOD.KEYBOARD:
		if action_state[action_name] == false and Input.is_joy_button_pressed( input_method, Controls.ui[action_name][0]) :
			action_state[action_name] = true
			return true
		if not Input.is_joy_button_pressed(input_method, Controls.ui[action_name][0]):
			action_state[action_name] = false
		return false
	else:
		if action_state[action_name] == false and Input.is_physical_key_pressed(Controls.ui[action_name][1]) :
			action_state[action_name] = true
			return true
		if not Input.is_physical_key_pressed(Controls.ui[action_name][1]):
			action_state[action_name] = false
		return false


func is_mapped_action_pressed(action_name : String) -> bool:
	if input_method != INPUT_METHOD.KEYBOARD:
		if Input.is_joy_button_pressed( input_method, Controls.ui[action_name][0]):
			return true
		else:
			return false
			
	else:
		if Input.is_physical_key_pressed(Controls.ui[action_name][1]):
			return true
		else:
			return false


func change_in_controllers():
		match Controls.connected_controllers:
			0: 
				if player_id == 0: input_method = 2
			1: 
				if player_id == 0: input_method = 0;
				elif player_id == 1: input_method = 2;
			2: 
				if player_id == 0: input_method = 0;
				elif player_id == 1: input_method = 1

@export var lobby_selection: Node2D 
@export var vbox : VBoxContainer

func _on_go_back_pressed() -> void:
	if lobby_selection.visible:
		lobby_selection.hide()
		vbox.show()
		pass
	pass # Replace with function body.
