extends Node2D

@export var player_1: Player 
@export var player_2: Player 


func _ready():
	
	var p1 : Player = GameManager.p1.instantiate()
	var p2 : Player = GameManager.p2.instantiate()
	
	add_child(p1); add_child(p2);
	p1.global_position = $spawn_p1.global_position
	p2.global_position = $spawn_p2.global_position
	
	p1.oponent = p2; p2.oponent = p1;
	p1.player_id = 0; p2.player_id = 1
	p1.player_num = 1; p2.player_num = 2
	
	p1.fully_instanciated.emit(); p2.fully_instanciated.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
