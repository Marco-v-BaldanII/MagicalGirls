extends Control
class_name CharacterSelect

@export var selected_index : int = 0
@export var selected_index2 : int = 0

@export var grid_width : int = 2
@onready var grid_container : Node2D = $Camera2D/characters
@onready var banner_texture_rect : TextureRect = $Camera2D/TextureRect

#Banner 1
@onready var texture_rect := $Camera2D/TextureRect
@onready var positionn := $Camera2D/Position
@onready var position_down := $Camera2D/PositionDown

#Banner 2
@onready var texture_rect2 := $Camera2D/TextureRect2
@onready var positionn2 := $Camera2D/Position2
@onready var position_down2 := $Camera2D/PositionDown2

@onready var select_character: AudioStreamPlayer = $Camera2D/SelectCharacter

@export var current_map : PackedScene 

@onready var p1_control_selection: ScrollMenu = $Camera2D/ControlSelection/P1_control_selection
@onready var p2_control_selection: ScrollMenu = $Camera2D/ControlSelection2/P2_control_selection


var input_methods : Array[INPUT_METHOD]

enum match_mode {
	
	LOCAL_2P,
	ONLINE_2P,
	CPU,
	ARCADE,
	TRAINING
	
}

var mode : match_mode = match_mode.CPU

var move_speed: float = 7000  
var choose_cooldown: float = 0  
var choose_cooldown2: float = 0  

var offscreen_position: Vector2
var real_target_position: Vector2
var target_position: Vector2  

var target_position2 : Vector2

var selected_fighter : String = ""
var selected_fighter2 : String = ""

var character_banners = {
	"Ritsu": preload("res://Assets/characters/concepts/RitsuConcept.png"),
	"Anastasia": preload("res://Assets/characters/concepts/Magical_Girl_Game_Jam_Anastasia_concept-ezgif.com-crop.png"),
	"Ellie Quinn": preload("res://Assets/characters/concepts/EllieQuinnConcept.png"),
	"Random": preload("res://Assets/PlaceHolders/goku_spsheet.png"),

}

func _ready():
	GDSync.expose_node(self)
	_update_selection(0)
	_update_selection(1)
	offscreen_position = position_down.position
	texture_rect.position = offscreen_position  
	target_position = texture_rect.position 
	target_position2 = texture_rect2.position
	real_target_position = positionn.position
	
	mode = GameManager.character_selection_mode
	input_methods = [2,2]
	remap_controllers()
	Controls.changed_controllers.connect(remap_controllers)
	
	
	_update_selection(0,false); _update_selection(1,false)
	
	await GameManager.online_setup
	
	reset_indexes()
	GDSync.call_func(reset_indexes)
	

func reset_indexes():
	selected_index = 0; selected_index2 = 0;
	
	
func _input(event: InputEvent) -> void:
	if Controls.is_ui_action_pressed("start"):
		_on_start_button_button_down()

func _process(delta: float) -> void:
	if texture_rect.position != target_position:
		var direction = (target_position - texture_rect.position).normalized()
		texture_rect.position += direction * move_speed * delta

		if (texture_rect.position - target_position).length() < move_speed * delta:
			texture_rect.position = target_position
	
	if texture_rect2.position != target_position2:
		var direction = (target_position2 - texture_rect2.position).normalized()
		texture_rect2.position += direction * move_speed * delta

		if (texture_rect2.position - target_position2).length() < move_speed * delta:
			texture_rect2.position = target_position2

	choose_cooldown += delta
	choose_cooldown2 += delta
	
	if(choose_cooldown >= .3) and not p1_control_selection._is_active:
		#Player 1
		if not GameManager.online or GameManager.is_host:
			input_movement(0)
			
	if(choose_cooldown2 >= .3) and not p2_control_selection._is_active and mode != match_mode.ARCADE:
		#Player 2
		if not GameManager.online and mode == match_mode.LOCAL_2P:
			input_movement(1)
		elif  not GameManager.is_host and mode == match_mode.ONLINE_2P:
			input_movement(0, true)
			
		elif selected_fighter != "" and (mode == match_mode.CPU or mode == match_mode.TRAINING):
			input_movement(0, true)

var back : bool = false

func input_movement(character_id : int, second_onlineP : bool = false):
	if ((character_id == 0 and selected_fighter == "") or (character_id == 0 and selected_fighter2 == "" and second_onlineP)) or (character_id == 1 and selected_fighter2 == ""):
		if is_joy_button_just_pressed("move_up", input_methods[character_id]) or( Input.get_joy_axis(character_id, JOY_AXIS_LEFT_Y) < -0.5 and input_methods[character_id] != INPUT_METHOD.KEYBOARD):
			select_character.play()
			move_selection(-1,character_id, second_onlineP) 
			GDSync.call_func(move_selection,[-1,character_id,second_onlineP])
		elif is_joy_button_just_pressed("move_down", input_methods[character_id]) or (Input.get_joy_axis(character_id, JOY_AXIS_LEFT_Y) > 0.5 and input_methods[character_id] != INPUT_METHOD.KEYBOARD):
			select_character.play()
			move_selection(+1,character_id,second_onlineP)  
			GDSync.call_func(move_selection,[+1,character_id,second_onlineP])
		elif is_joy_button_just_pressed("move_left", input_methods[character_id]) or (Input.get_joy_axis(character_id, JOY_AXIS_LEFT_X) < -0.5 and input_methods[character_id] != INPUT_METHOD.KEYBOARD):
			select_character.play()
			move_selection(-2,character_id,second_onlineP) 
			GDSync.call_func(move_selection,[-2,character_id,second_onlineP],)
		elif is_joy_button_just_pressed("move_right", input_methods[character_id]) or (Input.get_joy_axis(character_id, JOY_AXIS_LEFT_X) > 0.5 and input_methods[character_id] != INPUT_METHOD.KEYBOARD):
			select_character.play()
			move_selection(2,character_id,second_onlineP) 
			GDSync.call_func(move_selection,[2,character_id,second_onlineP])
		elif Controls.is_ui_action_pressed("accept"):
			while Controls.is_ui_action_pressed("accept"):
				await get_tree().create_timer(0.017).timeout
			
			$Camera2D/MenuSelect.play()
			_select_fighter(character_id, second_onlineP)
			GDSync.call_func(_select_fighter,[character_id,second_onlineP])

	if (input_methods[character_id] != 2 and Input.is_joy_button_pressed(input_methods[character_id], Controls.ui["go_back"][0])) or (input_methods[character_id] == 2 and Input.is_physical_key_pressed(Controls.ui["go_back"][1])):

			if not back:
				back = true
				
				while (input_methods[character_id] != 2 and Input.is_joy_button_pressed(input_methods[character_id], Controls.ui["go_back"][0])) or (input_methods[character_id] == 2 and Input.is_physical_key_pressed(Controls.ui["go_back"][1])):
					await get_tree().create_timer(0.017).timeout
				
				_on_go_back_button_down()
				
				$Camera2D/MenuSelect.play()
				if mode == match_mode.CPU:
					if selected_fighter2 != "": selected_fighter2 = ""
					else: selected_fighter = ""
				else:
					
					if character_id == 0 and not second_onlineP:
						selected_fighter = ""
					else:
						selected_fighter2 = ""
				back = false

func move_selection(offset: int, player : int = 0, second_onlineP : bool = false):
	
	var children_count = grid_container.get_child_count()
	var new_index : int
	var actual_player_index : int
	if player == 0 and not second_onlineP: actual_player_index = selected_index
	else: actual_player_index = selected_index2
	
	
	if actual_player_index == 3 and offset== 1:
		offset = -1
	elif actual_player_index == 2 and offset == 1:
		offset = 2
	elif actual_player_index == 0 and offset == -1:
		offset = 2
	elif actual_player_index == 2 and offset == -2:
		offset = -1
	elif actual_player_index == 2 and offset == 2:
		offset = 1
		
	elif actual_player_index == 0 and offset == -2:
		offset = 1
	elif actual_player_index == 0 and offset == 2:
		offset = 3
		
	elif actual_player_index == 3 and offset == -1:
		offset = -3
		
	elif actual_player_index == 1 and offset == -2:
		offset = 2
		
	elif actual_player_index == 2 and offset == -1:
		offset = 1
	
	if player == 0 and not second_onlineP:
		new_index = selected_index + offset
		actual_player_index = selected_index
	else:
		new_index = selected_index2 + offset
		actual_player_index = selected_index2
	
	
	
	#if offset == -1 and actual_player_index % grid_width == 0:
		#new_index = actual_player_index + (grid_width - 1)
	#
	#elif offset == 1 and (actual_player_index + 1) % grid_width == 0:
		#new_index = actual_player_index - (grid_width - 1)
	#
	#elif offset == -grid_width and new_index < 0:
		#new_index = (children_count - grid_width) + (actual_player_index % grid_width)
		#if new_index >= children_count:
			#new_index -= grid_width
	#
	#elif offset == grid_width and new_index >= children_count:
		#new_index = actual_player_index % grid_width
	
	
	new_index = new_index%children_count
	if new_index < 0:
		new_index = 0
	elif new_index >= children_count:
		new_index = children_count - 1
	
	if player == 0 and not second_onlineP:
		selected_index = new_index
	else:
		selected_index2 = new_index
	_update_selection(player, second_onlineP)
	
	if player == 0 and not second_onlineP: choose_cooldown = 0
	else: choose_cooldown2 = 0

func _update_selection(player : int = 0, second_onlineP : bool = false):
	var actual_player_index : int
	
	if player == 0 and not second_onlineP:
		actual_player_index = selected_index
	else:
		actual_player_index = selected_index2
	
	
	var children = grid_container.get_children()
	for i in range(children.size()):
		if children[i] != children[selected_index] and children[i] != children[selected_index2]:
		
			children[i].modulate = Color(1, 1, 1, 0.5) 
	if children.size() > 0 and actual_player_index < children.size():
		children[actual_player_index].modulate = Color(1, 1, 1, 1)  
	
	if player == 0 and not second_onlineP:
		
		var selected_child = children[actual_player_index]
		if character_banners.has(selected_child.name):
			banner_texture_rect.texture = character_banners[selected_child.name]


		texture_rect.position = offscreen_position
		target_position = real_target_position
	else:
		var selected_child = children[actual_player_index]
		if character_banners.has(selected_child.name):
			texture_rect2.texture = character_banners[selected_child.name]


		texture_rect2.position = position_down2.position
		target_position2 = positionn2.position

func _select_fighter(player : int = 0, second_onlineP : bool = false):
	var children = grid_container.get_children()
	if children.size() > 0 and selected_index < children.size():
		if player == 0 and not second_onlineP:
			selected_fighter = children[selected_index].name
			print("Selected fighter: ", selected_fighter)
		else:
			selected_fighter2 = children[selected_index2].name
			print("Selected fighter: ", selected_fighter2)


func _on_start_button_button_down() -> void:
	if mode != match_mode.ARCADE and selected_fighter != "" and selected_fighter2 != "":
		
		start_match()
		GDSync.call_func(start_match)
		
	elif mode == match_mode.ARCADE and selected_fighter != "":

			
			var arcade_route : ArcadeRun = load("res://ArcadeRuns/" + selected_fighter + ".tres")
			GameManager.arcade_route = arcade_route
			
			selected_fighter2 = arcade_route.oponents[0] #first oponent
			start_match()

var transitioned : bool = false

func start_match():
	if mode != match_mode.ONLINE_2P:
		if selected_fighter == "Random": selected_fighter = random_character()
		if selected_fighter2 == "Random" : selected_fighter2 = random_character()
	
	
	var p2_path : String = "res://Scenes/Entities/"
	if mode == match_mode.CPU or mode == match_mode.ARCADE: 
		p2_path = "res://Scenes/Entities/CPU/"
		selected_fighter2 += "_AI" #append suffix
	
	if not transitioned:
			if mode != match_mode.ONLINE_2P:
				GameManager.p1 = load("res://Scenes/Entities/"+selected_fighter+".tscn")
				GameManager.p2 = load(p2_path + selected_fighter2+".tscn")
			if mode == match_mode.ARCADE:
				SceneWrapper.change_scene(current_map)
				transitioned = true
			elif mode != match_mode.ONLINE_2P:
				SceneWrapper.change_scene(load("res://Scenes/menu_scenes/StageSelectionScreen.tscn"))
				transitioned = true
			elif GameManager.is_host:
					if selected_fighter == "Random": selected_fighter = random_character()
					if selected_fighter2 == "Random" : selected_fighter2 = random_character()
					
					online_characters_consistent(selected_fighter,selected_fighter2)
					GDSync.call_func(online_characters_consistent,[selected_fighter, selected_fighter2])
					
					await get_tree().create_timer(1).timeout
					
					
					var id : int = randi_range(1,4)
					var stage : String
					match id:
							1: stage = "Ritsu"
							2: stage = "Anastasia"
							3: stage = "Ellie"
							4: stage = "Larissa"
						
					online_random_map(stage)
					GDSync.call_func(online_random_map,[stage])
						
					start_online_match()
					GDSync.call_func(start_online_match)

func online_characters_consistent(char1 : String, char2 : String):
	GameManager.p1 = load("res://Scenes/Entities/"+char1+".tscn")
	GameManager.p2 = load("res://Scenes/Entities/"+char2+".tscn")
	pass

func online_random_map(stage : String):

	GameManager.back_ground = load("res://Scenes/Stages/parallax/" + stage + ".tscn")

func start_online_match():
	transitioned = true
	SceneWrapper.change_scene(load("res://Scenes/Stages/test_map2_deprecated.tscn"))

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"move_down" : false,
	"move_up" : false,
	"w_punch" : false,
	"s_punch" : false,
	"w_kick" : false,
	"s_kick" : false,
	"accept" : false,
	"go_back" : false
}

enum INPUT_METHOD{
	CONTROLLER_1,
	CONTROLLER_2,
	KEYBOARD
}

func is_joy_button_just_pressed(action_name : String, input_method : int = 0) -> bool:
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


func is_mapped_action_pressed(action_name : String, input_method : int = 0) -> bool:
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


func remap_controllers():
	match Controls.connected_controllers:
		0: 
			input_methods[0] = 2 #Player1 uses keyboard
		1: 
			input_methods[0] = 0; input_methods[1] = 2; #Player1 uses controller and p2 uses keyboard
		2: 
			input_methods[0] = 0; input_methods[1] = 1; #Player1 uses controller and p2 uses controller


func _on_go_back_button_down() -> void:
	if mode == match_mode.ONLINE_2P: 
		GDSync.close_lobby()
		GDSync.stop_multiplayer()
		GameManager.online = false
		SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))
	
	elif mode == match_mode.LOCAL_2P and selected_fighter == "" and selected_fighter2 == "":
		SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))
		
	elif mode == match_mode.ARCADE or mode == match_mode.CPU or mode == match_mode.TRAINING and selected_fighter == "":
		SceneWrapper.change_scene(load("res://Scenes/menu_scenes/menu.tscn"))

func random_character() ->String:
	var id = randi_range(1,3)
	
	match id:
		1: return "Ritsu"
		2:return "Anastasia"
		3: return "Ellie Quinn"
	return "Ritsu"
