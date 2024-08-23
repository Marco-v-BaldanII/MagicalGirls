extends CanvasLayer

@export var player : Player
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var buttons : Array[TextureRect]
var order : Array[int]
var curret_order :
	set(value):
		reset_time = 2.0
		curret_order = value
		for i in order.size():
			if order[i] == curret_order-1:
				buttons[i].modulate.a = 1
			else:
				buttons[i].modulate.a = 0.5

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
	
	#traducirlo
	var id = id_to_button(Controls.p1[input])
	
	for i in buttons.size():
		if buttons[i].texture == null:
			var res : ControllerIconTexture = ControllerIconTexture.new()
			
			#This is the translation bc the pluggin actually doesnt work super well
			if id == "s_kick":input = "s_punch"
			elif id == "s_punch":input = "w_punch"
			elif id == "w_punch" : input = "w_kick"
			elif id == "w_kick" : input = "s_kick"
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
	if id == "s_kick":input = "s_punch"
	elif id == "s_punch":input = "w_punch"
	elif id == "w_punch" : input = "w_kick"
	elif id == "w_kick" : input = "s_kick"
	res.path = input
	button_new.texture = res
	
	pass

#	"w_punch" : 2,
	#"s_punch" : 3,
	#"w_kick" : 0,
	#"s_kick" : 1

func id_to_button(id : int) -> String:
	match id:
		0: return "w_kick"
		1: return "s_kick"
		2: return "w_punch"
		3: return "s_punch"
	return "none"
