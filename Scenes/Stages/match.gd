extends Node2D
class_name Match

var p1 : Player
var p2 : Player 

@onready var camera: CharacterBody2D = $Camera
const BALLOON = preload("res://Dialogues/balloon.tscn")
var baloon = null
@onready var background: Node = $Background
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	
	p1 = GameManager.p1.instantiate()
	p2  = GameManager.p2.instantiate()
	

	p1.global_position = $spawn_p1.global_position
	p2.global_position = $spawn_p2.global_position
	
	p1.player_num = 1; p2.player_num = 2
	p1.oponent = p2; p2.oponent = p1;
	
	if not GameManager.online:
		p1.player_id = 0; p2.player_id = 1
	else:
		p1.player_id = 0; p2.player_id = 0
	
	if GameManager.online and GameManager.is_host:
		await get_tree().create_timer(0.4).timeout
		GDSync.set_gdsync_owner(p1, GDSync.get_client_id())
	else:
		
		GDSync.set_gdsync_owner(p2, GDSync.get_client_id())
		
	p1.match_setting = self; p2.match_setting = self;
	add_child(p1); add_child(p2);
	
	#color variant
	if p1.character_name == p2.character_name:
		p2.sprite_2d.texture = load("res://Assets/characters/" + p2.character_name + "/Animations/spritesheet_alt.png")
	
	var parallax : PackedScene

	if GameManager.character_selection_mode == 3 : #show dialogues in arcade mode
		
			#pick the cpu map
		parallax  = load("res://Scenes/Stages/parallax/" + p2.character_name + ".tscn")
		if parallax != null:
			var p = parallax.instantiate()
			background.add_child(p)
			
		if FileAccess.file_exists(("res://Dialogues/" + p1.character_name +".dialogue")) and GameManager.total_set_matches() == 0:
			baloon = BALLOON.instantiate()
			
		
			await get_tree().create_timer(0.4).timeout
			
			var dialogue_resource : DialogueResource = load("res://Dialogues/" + p1.character_name +".dialogue")
			var title : String = p2.character_name
			add_child(baloon)
			if title == "Ellie Quinn": 
				title = "EllieQuinn"

			baloon.start(dialogue_resource, title)
	
			
		while is_instance_valid(baloon):
			await get_tree().create_timer(0.017).timeout
	else:
		parallax  = GameManager.back_ground
		if parallax != null:
			var p = parallax.instantiate()
			background.add_child(p)
			await get_tree().create_timer(0.01667*20).timeout
			
	if GameManager.character_selection_mode == 4: #max mp in training mode
		p1.mp = 600; p2.mp = 600
	
	await get_tree().create_timer(0.3).timeout
	$AnimationPlayer.play("start")
	await get_tree().create_timer(0.01667*84).timeout
	
	remap_controllers()
	
	p1.fully_instanciated.emit(); p2.fully_instanciated.emit()
	p1.can_move = true; p2.can_move = true;
	p2.is_initialized = true; p1.is_initialized = true

	if not GameManager.online:
		
		var connected_controllers = Input.get_connected_joypads()
		var num_connected = connected_controllers.size()
		
		match num_connected:
			0: 
				p1.input_method = 2 #Player1 uses keyboard
			1: 
				p1.input_method = 0; p2.input_method = 2; #Player1 uses controller and p2 uses keyboard
			2: 
				p1.input_method = 0; p2.input_method = 1; #Player1 uses controller and p2 uses controller


	
	#These are basically so that online nodes dont get confused when spawning 2 simoultaneous instance of the same projectile
	GameManager.p1_spawns = $player1_spawns; GameManager.p2_spawns = $player2_spawns2
	p1.player_died.connect(GameManager.match_results); p2.player_died.connect(GameManager.match_results)
	
	GameManager.initialized_players.emit(p1 ,p2)
	
	Controls.changed_controllers.connect(remap_controllers)
	started = true
	#p2.queue_free()
var started : bool = false
var time : float = 99.0

@onready var timer_label: Label = $CanvasLayer/timer_label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started:
		time -= delta
		timer_label.text = str(floori(time))
		
	if time <= 0:
		if p1.hp < p2.hp:
			GameManager.match_results(2)
		elif p1.hp > p2.hp:
			GameManager.match_results(1)
		else:
			GameManager.match_results(-1)
			#Tie
		time = 99

		
	pass

func remap_controllers():
	print("called remap controlers")
	if not GameManager.online:
		
		match Controls.connected_controllers:
			0: 
				p1.input_method = 2 #Player1 uses keyboard
			1: 
				p1.input_method = 0; p2.input_method = 2; #Player1 uses controller and p2 uses keyboard
			2: 
				p1.input_method = 0; p2.input_method = 1; #Player1 uses controller and p2 uses controller
			_: 
				p1.input_method = 0; p2.input_method = 1; #Player1 uses controller and p2 uses controller
	else:
		
		var my_player : Player = null
		if GameManager.is_host:
			my_player = p1
		else:
			my_player = p2
			
		match Controls.connected_controllers:
			0: 
				my_player.input_method = 2 #Player1 uses keyboard
				print("connected to keyboard")
			1: 
				my_player.input_method = 0; 
				print("connected to gamepad")
			_: 
				p1.input_method = 0; 
		
func _input(event: InputEvent) -> void:
	
	if Controls.is_joy_button_just_pressed("start"):
	
		if GameManager.character_selection_mode != 1:
			Pause.activate()

	
func match_ko():
	animation_player.play("K.O")
