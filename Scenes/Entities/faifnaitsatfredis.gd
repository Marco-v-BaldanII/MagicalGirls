extends TextureProgressBar
@onready var player: Player = $"../.."

@export var regenerate : bool = false
var second_timer = 0.8
@export var incerement_value = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_mode = FILL_RIGHT_TO_LEFT

	await get_tree().create_timer(0.01).timeout
	if player.direction == "left":
		position = Vector2(42,position.y)
	else:
		position = Vector2(1038,position.y)
		
	# Set the broadcaster to be the computer of the player that actually controls the player
	#if GDSync.is_gdsync_owner(player):
		#
		#if GDSync.is_host():
			##if i am the host and the owner , the host broadcasts
			#property_synchronizer.broadcast = 0
		#else:
			##if i am client and owner , client broadcasts
			#property_synchronizer.broadcast = 1
			#
		#
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	
	if regenerate:
		second_timer -= delta
		if second_timer <= 0:
			second_timer = 1.0
			value += incerement_value
	
	pass
