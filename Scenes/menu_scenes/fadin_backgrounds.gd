extends Node2D

var time : float = 6.5
@onready var panel: Panel = $Panel
@export var backgrounds : Array[ParallaxBackground]

@onready var current_background = $RitsuBG

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_target_pos.x = randf_range(-335,445)
	pass # Replace with function body.

@onready var camera_2d: Camera2D = $".."

var lerping_back : bool = false

var camera_target_pos : Vector2 = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	time -= delta
	
	if time <0 and not lerping_back:
		var color : Color = panel.modulate
		color = color.lerp(Color.WHITE,0.03)
		panel.modulate = color
		if time < - 0.8:
			if camera_target_pos.x == -335: camera_target_pos.x = 445
			else: camera_target_pos.x = -335

			
			lerping_back = true
			if current_background: current_background.hide()
			var background : ParallaxBackground = current_background
			while background == current_background:
				background = backgrounds.pick_random()
			current_background = background
			current_background.show()
	
	if camera_2d.position.x != camera_target_pos.x:
		camera_2d.position.x = lerp(camera_2d.position.x,camera_target_pos.x, delta/2)
	
	if lerping_back:
		var color : Color = panel.modulate
		color = color.lerp(Color(0.28,0.11,0.26,0.4),0.03)
		panel.modulate = color
		
		if time < -1.6:
			time = randf_range(6.5,10.0)
			lerping_back = false
	
	pass
