extends Control
class_name ControlerMenu
@onready var scroll_container: ScrollMenu = $".."

const CONTROLER_OPTION = preload("res://Scenes/menu_scenes/controler_option.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lis : Array =load_resources_from_directory("res://ControlSchemes/")
	
	for scheme in lis:
		var control_scheme = CONTROLER_OPTION.instantiate()
		add_child(control_scheme)
		control_scheme.label.text = scheme.my_name
		#scroll_container.options.push_back(control_scheme)
	#var connected_controllers = Input.get_connected_joypads()
	#var num_connected = connected_controllers.size()
	#
	#for i in num_connected:
		#var controler_opt = CONTROLER_OPTION.instantiate()
		#add_child(controler_opt)
		#controler_opt.label.text = "Controler " + str(i+1)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_resources_from_directory(dir_path: String) -> Array:
	var dir = DirAccess.open(dir_path)
	var loaded_resources = []
	
	# Open the directory
	if dir.get_open_error() == OK:
		dir.list_dir_begin()  # Begin listing the directory
		
		var file_name = dir.get_next()
		
		# Loop through all items in the directory
		while file_name != "":
			# Skip directories and hidden files (like . and ..)
			if !dir.current_is_dir():
				# Construct the full path of the resource
				var file_path = dir_path + "/" + file_name
				
				
				var resource = ResourceLoader.load(file_path)
				
				if resource:
					loaded_resources.append(resource)
				else:
					print("Failed to load resource: ", file_path)
			
			# Move to the next file
			file_name = dir.get_next()
		
		dir.list_dir_end()  # End directory listing
	else:
		print("Failed to open directory: ", dir_path)
	
	return loaded_resources
