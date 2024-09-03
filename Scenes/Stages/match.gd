extends Node2D
class_name Match

var p1 : Player
var p2 : Player 

@onready var camera: CharacterBody2D = $Camera
const BALLOON = preload("res://Dialogues/balloon.tscn")
var baloon = null
@onready var background: Node = $Background

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
	
	if GameManager.is_host:
		GDSync.set_gdsync_owner(p1, GDSync.get_client_id())
	else:
		GDSync.set_gdsync_owner(p2, GDSync.get_client_id())
		
	p1.match_setting = self; p2.match_setting = self;
	add_child(p1); add_child(p2);
	
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
	
	$AnimationPlayer.play("start")
	await get_tree().create_timer(0.01667*84).timeout
	
	p1.fully_instanciated.emit(); p2.fully_instanciated.emit()
	p1.can_move = true; p2.can_move = true;
	p2.is_initialized = true; p1.is_initialized = true
	#p2.calculate_direction(); p1.calculate_direction()
	
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
	
	#p2.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func remap_controllers():
	match Controls.connected_controllers:
		0: 
			p1.input_method = 2 #Player1 uses keyboard
		1: 
			p1.input_method = 0; p2.input_method = 2; #Player1 uses controller and p2 uses keyboard
		2: 
			p1.input_method = 0; p2.input_method = 1; #Player1 uses controller and p2 uses controller
