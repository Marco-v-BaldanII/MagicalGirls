extends Control

@export var selected_index : int = 0
@export var selected_index2 : int = 0

@export var grid_width : int = 3 
@onready var grid_container : GridContainer = $GridContainer
@onready var banner_texture_rect : TextureRect = $TextureRect


@onready var texture_rect = $TextureRect
@onready var positionn = $Position
@onready var position_down = $PositionDown

@export var current_map : PackedScene 

var move_speed: float = 7000  
var choose_cooldown: float = 0  
var choose_cooldown2: float = 0  

var offscreen_position: Vector2
var real_target_position: Vector2
var target_position: Vector2  

var selected_fighter : String = ""
var selected_fighter2 : String = ""

var character_banners = {
	"TextureRect1": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect2": preload("res://Assets/PlaceHolders/goku_spsheet.png"),
	"TextureRect3": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect4": preload("res://Assets/PlaceHolders/goku_spsheet.png"),
	"TextureRect5": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect6": preload("res://Assets/PlaceHolders/bomb.png"),
}

func _ready():
	GDSync.expose_node(self)
	_update_selection(0)
	_update_selection(1)
	offscreen_position = position_down.position
	texture_rect.position = offscreen_position  
	target_position = texture_rect.position 
	real_target_position = positionn.position
	
	await GameManager.online_setup
	
	reset_indexes()
	GDSync.call_func(reset_indexes)

func reset_indexes():
	selected_index = 0; selected_index2 = 0;

func _process(delta: float) -> void:
	if texture_rect.position != target_position:
		var direction = (target_position - texture_rect.position).normalized()
		texture_rect.position += direction * move_speed * delta

		if (texture_rect.position - target_position).length() < move_speed * delta:
			texture_rect.position = target_position
	choose_cooldown += delta
	choose_cooldown2 += delta
	
	if(choose_cooldown >= .3):
		#Player 1
		if not GameManager.online or GameManager.is_host:
			input_movement(0)
			
	if(choose_cooldown2 >= .3):
		#Player 2
		if not GameManager.online:
			input_movement(1)
		elif  not GameManager.is_host:
			input_movement(0, true)


func input_movement(character_id : int, second_onlineP : bool = false):
	if ((character_id == 0 and selected_fighter == "") or (character_id == 0 and selected_fighter2 == "" and second_onlineP)) or (character_id == 1 and selected_fighter2 == ""):
		if Input.is_joy_button_pressed(character_id, Controls.ui["move_up"]) or Input.get_joy_axis(character_id, JOY_AXIS_LEFT_Y) < -0.5:
			$SelectCharacter.play()
			move_selection(-grid_width,character_id, second_onlineP) 
			GDSync.call_func(move_selection,[-grid_width,character_id,second_onlineP])
		elif Input.is_joy_button_pressed(character_id, Controls.ui["move_down"]) or Input.get_joy_axis(character_id, JOY_AXIS_LEFT_Y) > 0.5:
			$SelectCharacter.play()
			move_selection(grid_width,character_id,second_onlineP)  
			GDSync.call_func(move_selection,[grid_width,character_id,second_onlineP])
		elif Input.is_joy_button_pressed(character_id, Controls.ui["move_left"]) or Input.get_joy_axis(character_id, JOY_AXIS_LEFT_X) < -0.5:
			$SelectCharacter.play()
			move_selection(-1,character_id,second_onlineP) 
			GDSync.call_func(move_selection,[-1,character_id,second_onlineP],)
		elif Input.is_joy_button_pressed(character_id, Controls.ui["move_right"]) or Input.get_joy_axis(character_id, JOY_AXIS_LEFT_X) > 0.5:
			$SelectCharacter.play()
			move_selection(1,character_id,second_onlineP) 
			GDSync.call_func(move_selection,[1,character_id,second_onlineP])
		elif Input.is_joy_button_pressed(character_id, Controls.ui["accept"]):
			$MenuSelect.play()
			_select_fighter(character_id, second_onlineP)
			GDSync.call_func(_select_fighter,[character_id,second_onlineP])
	else:
		if Input.is_joy_button_pressed(character_id, Controls.ui["go_back"]):
			$MenuSelect.play()
			
			if character_id == 0 and not second_onlineP:
				selected_fighter = ""
			else:
				selected_fighter2 = ""

func move_selection(offset: int, player : int = 0, second_onlineP : bool = false):
	
	var children_count = grid_container.get_child_count()
	var new_index : int
	var actual_player_index : int
	
	if player == 0 and not second_onlineP:
		new_index = selected_index + offset
		actual_player_index = selected_index
	else:
		new_index = selected_index2 + offset
		actual_player_index = selected_index2

	if offset == -1 and actual_player_index % grid_width == 0:
		new_index = actual_player_index + (grid_width - 1)
	
	elif offset == 1 and (actual_player_index + 1) % grid_width == 0:
		new_index = actual_player_index - (grid_width - 1)
	
	elif offset == -grid_width and new_index < 0:
		new_index = (children_count - grid_width) + (actual_player_index % grid_width)
		if new_index >= children_count:
			new_index -= grid_width
	
	elif offset == grid_width and new_index >= children_count:
		new_index = actual_player_index % grid_width

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
	
	var selected_child = children[actual_player_index]
	if character_banners.has(selected_child.name):
		banner_texture_rect.texture = character_banners[selected_child.name]

	texture_rect.position = offscreen_position
	target_position = real_target_position

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
	if selected_fighter != "" and selected_fighter2 != "":
		
		start_match()
		GDSync.call_func(start_match)

func start_match():
	if FileAccess.file_exists("res://Scenes/Entities/"+selected_fighter+".tscn") and FileAccess.file_exists("res://Scenes/Entities/"+selected_fighter2+".tscn"):
			
			GameManager.p1 = load("res://Scenes/Entities/"+selected_fighter+".tscn")
			GameManager.p2 = load("res://Scenes/Entities/"+selected_fighter2+".tscn")
			
			SceneWrapper.change_scene(current_map)
