extends ProgressBar
@onready var player: Player = $"../.."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.01).timeout
	if player.direction == "left":
		position = Vector2(42,38)
	else:
		position = Vector2(1038,38)
		fill_mode = FILL_END_TO_BEGIN
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
