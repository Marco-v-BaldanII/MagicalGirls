extends Option
@onready var move_pages: Node2D = $"../../../MovePages"

func execute_option() -> bool:
	
	if not move_pages.visible:
		move_pages.show()
	
	return true
