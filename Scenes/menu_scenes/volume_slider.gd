extends HSlider

@export var bus_name: String

var bus_index: int
var selected : bool = false

func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_on_value_changed)
	
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value)
	)

func execute_option():
	selected = true
	modulate = Color.DARK_ORANGE
	
func deselect():
	selected = false
	modulate = Color.WHITE
	
func _process(delta: float) -> void:
	if selected:
		if Controls.is_ui_action_pressed("move_right"):
			value += 0.05
		elif Controls.is_ui_action_pressed("move_left"):
			value -= 0.05
