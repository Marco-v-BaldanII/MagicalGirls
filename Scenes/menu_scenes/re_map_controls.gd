extends CanvasLayer
@onready var cursor: Sprite2D = $cursor
@onready var grid_container: GridContainer = $GridContainer

var input_boxes : Array
@onready var button: Button = $Button
@onready var text_edit: TextEdit = $TextEdit

var index : int = 0

var listening_input : bool = false

@onready var current_controls : ControlSource = ControlSource.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#current_controls = ControlSource.new()
	
	for child in grid_container.get_children():
		if child is InputMapBox:
			input_boxes.push_back(child)
			
	input_boxes.push_back(button)
	input_boxes.push_back(text_edit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if not listening_input:
		if Controls.is_joy_button_just_pressed("move_up"):
			index -= 1
			
		elif Controls.is_joy_button_just_pressed("move_down"):
			index += 1
		
		cursor.global_position.y = input_boxes[index % input_boxes.size()].global_position.y +  40
		
		
		if Controls.is_ui_action_pressed("go_back") and not text_edit.has_focus():
			_on_go_back_button_down()
		
		if Controls.is_joy_button_just_pressed("accept"):
			if input_boxes[index % input_boxes.size()] is not Button and input_boxes[index % input_boxes.size()] is not TextEdit:
				listening_input = true
				input_boxes[index % input_boxes.size()].modulate = Color.YELLOW
			elif input_boxes[index % input_boxes.size()] is  Button:
				_on_button_button_down()
			elif input_boxes[index % input_boxes.size()] is TextEdit:
				input_boxes[index % input_boxes.size()].grab_focus()
	else:
		
		if Controls.is_joy_button_just_pressed("s_punch"):
			reMap("s_punch")
		elif Controls.is_joy_button_just_pressed("w_punch"):
			reMap("w_punch")
		elif Controls.is_joy_button_just_pressed("s_kick"):
			reMap("s_kick")
		elif Controls.is_joy_button_just_pressed("w_kick"):
			reMap("w_kick")
			pass

func traduce_action(action : String) -> String:

	if action == "s_kick":return "s_punch"
	elif action == "s_punch":return  "w_punch"
	elif action == "w_punch" : return  "w_kick"
	elif action == "w_kick" : return  "s_kick"

	return action

func traduce_back(action : String) -> String:
	if action == "s_punch" : return "s_kick"
	elif action == "w_punch" : return "s_punch"
	elif action == "w_kick": return "w_punch"
	elif action == "s_kick": return "w_kick"
	
	return action

func reMap(action : String):
		for i in input_boxes:
			if i.my_action == traduce_action(action):
				i.re_map(traduce_back( input_boxes[index % input_boxes.size()].my_action))
				break
		input_boxes[index % input_boxes.size()].re_map(action)
		listening_input = false
		input_boxes[index % input_boxes.size()].modulate = Color.WHITE

func _on_button_button_down() -> void:
	#SceneWrapper.change_scene(load("res://Scenes/Stages/test_map.tscn"))
	
		# Define the path where you want to save the resource
	current_controls.my_name = text_edit.text
	
	var save_path = "res://ControlSchemes/" + text_edit.text + ".tres"

	# Save the resource to the specified path
	var error = ResourceSaver.save( current_controls ,save_path)

	# Check if the save was successful
	if error == OK:
		print("Resource saved successfully!")
	else:
		print("Failed to save resource with error code: ", error)
	
	pass # Replace with function body.


func _on_go_back_button_down() -> void:
	SceneWrapper.change_scene(load("res://Scenes/menu_scenes/Configuration.tscn"))
	pass # Replace with function body.
