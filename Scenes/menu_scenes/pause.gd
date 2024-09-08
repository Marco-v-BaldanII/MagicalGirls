extends CanvasLayer

@onready var node_2d: PauseMenu = $Node2D

var active : bool = false

func activate():
	active = true
	get_tree().paused = true
	show()
	node_2d.activate()
	
func deactivate():
	active = false
	get_tree().paused = false
	hide()
	node_2d.deactivate()
