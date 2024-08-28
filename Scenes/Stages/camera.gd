extends Camera2D

@onready var player1: Node2D
@onready var player2: Node2D

@export var horizontal_margin := 500.0 
@export var camera_speed := 300

@export var level_bounds: Rect2 = Rect2(Vector2(), Vector2(2048, 2048)) 

func _ready():

	GameManager.initialized_players.connect(init)
	
func init(p1 : Player , p2: Player):
	player1 = p1; player2 = p2;

func _process(delta: float) -> void:
	if not player1 or not player2:
		#print("One or both players are not assigned!")
		return 

	var midpoint_x := (player1.global_position.x + player2.global_position.x) / 2.0

	var target_position := global_position
	#if abs(player1.global_position.x - player2.global_position.x) > 1800:
	if abs(midpoint_x - global_position.x) > get_viewport().size.x * 0.08:
		target_position.x = midpoint_x
			
	#target_position.x = midpoint_x

	var new_position_x: float = lerp(global_position.x, target_position.x, camera_speed * delta)

	var level_min_x: float = level_bounds.position.x + get_viewport().size.x / 2
	var level_max_x: float = level_bounds.position.x + level_bounds.size.x - get_viewport().size.x / 2

	if level_min_x > level_bounds.position.x:
		level_min_x = level_bounds.position.x
	if level_max_x < level_bounds.position.x + level_bounds.size.x:
		level_max_x = level_bounds.position.x + level_bounds.size.x
	
	new_position_x = clamp(new_position_x, level_min_x, level_max_x)
	
	global_position.x = move_toward(global_position.x, target_position.x ,delta * camera_speed)
	

	#global_position.x = new_position_x
##
	#print("Player1 Position:", player1.global_position)
	#print("Player2 Position:", player2.global_position)
	#print("Midpoint:", midpoint_x)
	#print("Target Position:", target_position)
	#print("New Camera Position:", global_position)
