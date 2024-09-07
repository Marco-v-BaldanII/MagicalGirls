extends CanvasLayer

@onready var node_2d: PauseMenu = $Node2D

var active : bool = false

func activate():
	active = true
	Engine.time_scale = 0
	show()
	node_2d.activate()
	
func deactivate():
	active = false
	Engine.time_scale = 1
	hide()
	node_2d.deactivate()
