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
	pass
