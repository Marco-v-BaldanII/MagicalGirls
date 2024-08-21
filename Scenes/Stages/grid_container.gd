extends Control

@export var selected_index : int = 0
@export var grid_width : int = 3 
@onready var grid_container : GridContainer = $GridContainer
@onready var banner_texture_rect : TextureRect = $TextureRect
@onready var texture_rect = $TextureRect

var move_speed: float = 300.0  
var offscreen_position: Vector2 = Vector2(-500, 100)  
var target_position: Vector2  

var character_banners = {
	"TextureRect1": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect2": preload("res://Assets/PlaceHolders/goku_spsheet.png"),
	"TextureRect3": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect4": preload("res://Assets/PlaceHolders/goku_spsheet.png"),
	"TextureRect5": preload("res://Assets/PlaceHolders/bomb.png"),
	"TextureRect6": preload("res://Assets/PlaceHolders/bomb.png"),
}

func _ready():
	_update_selection()
	texture_rect.position = offscreen_position  
	target_position = texture_rect.position 

func _process(delta: float) -> void:
	if texture_rect.position != target_position:
		var direction = (target_position - texture_rect.position).normalized()
		texture_rect.position += direction * move_speed * delta

		if (texture_rect.position - target_position).length() < move_speed * delta:
			texture_rect.position = target_position

	if Input.is_action_just_pressed("ui_up"):
		move_selection(-grid_width)  
	elif Input.is_action_just_pressed("ui_down"):
		move_selection(grid_width)  
	elif Input.is_action_just_pressed("ui_left"):
		move_selection(-1) 
	elif Input.is_action_just_pressed("ui_right"):
		move_selection(1) 
	elif Input.is_action_just_pressed("ui_select"):
		_select_fighter()

func move_selection(offset: int):
	var children_count = grid_container.get_child_count()
	
	var new_index = selected_index + offset

	if offset == -1 and selected_index % grid_width == 0:
		new_index = selected_index + (grid_width - 1)
	
	elif offset == 1 and (selected_index + 1) % grid_width == 0:
		new_index = selected_index - (grid_width - 1)
	
	elif offset == -grid_width and new_index < 0:
		new_index = (children_count - grid_width) + (selected_index % grid_width)
		if new_index >= children_count:
			new_index -= grid_width
	
	elif offset == grid_width and new_index >= children_count:
		new_index = selected_index % grid_width

	if new_index < 0:
		new_index = 0
	elif new_index >= children_count:
		new_index = children_count - 1

	selected_index = new_index
	_update_selection()

func _update_selection():
	var children = grid_container.get_children()
	for i in range(children.size()):
		children[i].modulate = Color(1, 1, 1, 0.5) 
	if children.size() > 0 and selected_index < children.size():
		children[selected_index].modulate = Color(1, 1, 1, 1)  
	
	var selected_child = children[selected_index]
	if character_banners.has(selected_child.name):
		banner_texture_rect.texture = character_banners[selected_child.name]

	texture_rect.position = offscreen_position
	target_position = Vector2(100, 100) 

func _select_fighter():
	var children = grid_container.get_children()
	if children.size() > 0 and selected_index < children.size():
		var selected_fighter = children[selected_index]
		print("Selected fighter: ", selected_fighter.name)
