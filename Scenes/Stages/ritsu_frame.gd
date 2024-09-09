extends Sprite2D

var og_pos : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	og_pos = position
	pass # Replace with function body.

var shake_amount : int = 16

var shake: bool = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func shake_routine():
	if shake:
		show()
		var i = 0
		while i < 15:
			var cam_offset = Vector2(randf_range(-1,1) * shake_amount, randf_range(-1,1)*shake_amount)
			position += cam_offset
			await get_tree().create_timer(0.0167,true,false,true).timeout
			i += 1
	hide()
	position = og_pos
	pass
