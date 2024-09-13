extends Sprite2D

var glob_pos :Vector2
@onready var feet: CollisionShape2D = $".."

#var _scale : float:
	#set(value):
		#
		#value = clampf(value,)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	glob_pos = global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position.y = glob_pos.y
	
	if feet.global_position.distance_to(global_position) > 350:
		scale *= 0.96
	elif feet.global_position.distance_to(global_position) < 350:
		scale *= 1.06
	
	scale.x = clampf(scale.x,0.65*0.8, 2.75*0.8)
	scale.y = clampf(scale.y,0.15,0.65)
	
	pass
