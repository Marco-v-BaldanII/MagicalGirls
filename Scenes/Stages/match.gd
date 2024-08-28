extends Node2D

var p1 : Player
var p2 : Player

func _ready():
	
	p1 = GameManager.p1.instantiate()
	p2  = GameManager.p2.instantiate()
	
	add_child(p1); add_child(p2);
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
	
	p1.fully_instanciated.emit(); p2.fully_instanciated.emit()
	
	#These are basically so that online nodes dont get confused when spawning 2 simoultaneous instance of the same projectile
	GameManager.p1_spawns = $player1_spawns; GameManager.p2_spawns = $player2_spawns2
	GameManager.initialized_players.emit(p1 ,p2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
