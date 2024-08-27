extends Camera2D

@export var player1: Node2D
@export var player2: Node2D

@export var horizontal_margin := 500.0 
@export var camera_speed := 1.0

@export var level_bounds: Rect2 = Rect2(Vector2(), Vector2(2048, 2048)) 

func _ready() -> void:
	player1 = get_node("Anastasia")
	player2 = get_node("Anastasia2")

func _process(delta: float) -> void:
	if not player1 or not player2:
		print("One or both players are not assigned!")
		return 

	var midpoint_x := (player1.global_position.x + player2.global_position.x) / 2.0

	var target_position := global_position

	if abs(midpoint_x - global_position.x) > horizontal_margin:
		target_position.x = midpoint_x

	var new_position_x :float = lerp(global_position.x, target_position.x, camera_speed * delta)

	var level_min_x :float= level_bounds.position.x + get_viewport().size.x / 2
	var level_max_x :float= level_bounds.size.x - get_viewport().size.x / 2

	new_position_x = clamp(new_position_x, level_min_x, level_max_x)

	global_position.x = new_position_x
	
	print("Player1 Position:", player1.global_position)
	print("Player2 Position:", player2.global_position)
	print("Midpoint:", midpoint_x)
	print("Target Position:", target_position)
	print("New Camera Position:", global_position)
