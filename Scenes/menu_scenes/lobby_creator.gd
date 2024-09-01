extends Node2D
class_name LobbyCreator

@onready var lobby_name: TextEdit = $LobbyName
@onready var lobby_password: TextEdit = $LobbyPassword

@onready var check_button: CheckButton = $CheckButton


func _on_button_button_down() -> void:
	var password : String = "Password123"
	var public : bool = true
	
	if check_button.button_pressed:
		password = lobby_password.text
		public = false

	
	if GameManager.online:
		GDSync.create_lobby(
		lobby_name.text,
		password,
		true,
		10,
		{
			"public" : public
		}
		)
		#GDSync.set_gdsync_owner(player_1, GDSync.get_client_id())
		GameManager.is_host = true
		GameManager.joined_lobby.emit()
	
	pass # Replace with function body.


@onready var cursor = $"../cursor"
@export var cursor_offset : int = 5
@export var timer : float = 0.1 

var options : Array;

var num_options : int
var current_player : Player
var current_option 



var _index: int = 0
@export var _is_active : bool = true

func is_descendant_of(node: Node, potential_ancestor: Node) -> bool:
	
	return potential_ancestor.is_ancestor_of(node)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _is_active:
		deactivate()
	var opt = get_children()
	
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
	
	if options.size() > 0 and timer <= 0:

			if is_joy_button_just_pressed("move_down"):
				_index += 2
				while options[_index % options.size()].is_visible_in_tree() == false:
					_index += 2
				_change_cursor_pos()
				
					
			if is_joy_button_just_pressed("move_up"):
				_index -= 2
				while options[_index % options.size()].is_visible_in_tree() == false:
					_index -= 2
				_change_cursor_pos()
				
			if is_joy_button_just_pressed("move_right"):
				_index += 1
				while options[_index % options.size()].is_visible_in_tree() == false:
					_index += 1
				_change_cursor_pos()
				
					
			if is_joy_button_just_pressed("move_left"):
				_index -= 1
				while options[_index % options.size()].is_visible_in_tree() == false:
					_index -= 1
				_change_cursor_pos()
			
			if is_joy_button_just_pressed("accept") and current_option != null:
				timer = 0.15
				
				if current_option is Option:
					var  done : bool = current_option.execute_option()
					current_option.modulate = Color.SKY_BLUE

				elif current_option is Button :
					#Programatically press button
					current_option.pressed.emit()
					current_option.button_down.emit()
					if  current_option is CheckButton:
						current_option.button_pressed = !current_option.button_pressed
						print("cehck box pressed")




func _change_cursor_pos():
	
		timer = 0.15
	
		num_options = options.size()

		cursor.global_position.x = options[_index % num_options].global_position.x + cursor_offset
		current_option = options[_index % num_options]
		cursor.global_position.y = options[_index % num_options].global_position.y + cursor_offset
		current_option = options[_index % num_options]
		
		for option in options:
			if option != current_option:
				option.modulate = Color.WHITE
			else:
				option.modulate = Color.YELLOW

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

var action_state : Dictionary = {
	"move_left" : false,
	"move_right" : false,
	"move_down" : false,
	"move_up" : false,
	"accept" : false,
	"s_punch" : false,
	"w_kick" : false,
	"s_kick" : false
}

func is_joy_button_just_pressed(action_name : String) -> bool:

		if action_state[action_name] == false and (Input.is_joy_button_pressed( 0, Controls.ui[action_name][0]) or Input.is_physical_key_pressed(Controls.ui[action_name][1])) :
			action_state[action_name] = true
			return true
		if not Input.is_joy_button_pressed(0, Controls.ui[action_name][0]) and not Input.is_physical_key_pressed(Controls.ui[action_name][1]):
			action_state[action_name] = false
		return false
