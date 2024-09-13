extends Node2D
@onready var timer = $Timer
var finished: bool = false
var finish_cutscene: Signal


# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	pass # Replace with function body.




func _on_timer_timeout():
	finish_cutscene.emit()
	GameManager.finish_cutscene.emit()
	finished = true
	print(finished)
	pass # Replace with function body.
