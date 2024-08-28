extends Node2D
@onready var anastasia: Anastasia = $"../Anastasia"
@onready var anastasia_2: Anastasia = $"../Anastasia2"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position.x = (anastasia.global_position.x + anastasia_2.global_position.x) / 2
	pass
