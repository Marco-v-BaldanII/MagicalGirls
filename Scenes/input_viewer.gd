extends CanvasLayer

@export var player : Player
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var buttons : Array[TextureRect]
var order : Array[int]
var curret_order :
	set(value):
		reset_time = 2.0
		curret_order = value

var reset_time:
	set(value):
		if value < 0:
			for i in buttons.size():
				buttons[i].texture = null
				order[i] = i
		reset_time = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curret_order = 0; reset_time = 2.0
	
	for i in h_box_container.get_children():
		buttons.push_back(i)
		order.push_back(0)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	reset_time -= delta
	
	#if not player.input_buffer.is_empty():
#
		#var res : ControllerIconTexture = ControllerIconTexture.new()
		#res.path = player.input_buffer.back()
		##texture_rect.texture = res
	pass

func add_input(input : String):
	for i in buttons.size():
		if buttons[i].texture == null:
			var res : ControllerIconTexture = ControllerIconTexture.new()
			if input == "s_kick":input = "s_punch"
			elif input == "s_punch":input = "w_punch"
			elif input == "w_punch" : input = "w_kick"
			elif input == "w_kick" : input = "s_kick"
			res.path = input
			buttons[i].texture = res
			
			order[i] = curret_order
			curret_order += 1
			return
			
	#NO SPACE
	#must reorder children
	var lowest_order = 99999
	var button_new
	for i in order.size():
		if order[i] <= lowest_order:
			lowest_order = order[i]
			
			button_new = buttons[i]
			
	var i = order.find(lowest_order)
	order[i] = curret_order
	curret_order += 1
	
	var res : ControllerIconTexture = ControllerIconTexture.new()
	if input == "s_kick":input = "s_punch"
	elif input == "s_punch":input = "w_punch"
	elif input == "w_punch" : input = "w_kick"
	elif input == "w_kick" : input = "s_kick"
	res.path = input
	button_new.texture = res
	
	pass
