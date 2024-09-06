extends Node2D

@onready var player : Player = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	if player.direction == "left":
		#position = Vector2(25,position.y)
		pass
	else:
		position = Vector2(1922,position.y)
		scale.x *= -1
	pass # Replace with function body.
