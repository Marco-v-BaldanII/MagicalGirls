extends Node
class_name StateMachine

@export var initial_state : State

var current_state : State
var name_current_state : String
var states : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	#Loop through the children, if the child is a state, add it to the dictionary
	for child in get_children():
		if child is State:
			states[child.name] = child
			
			#Connect the function to the transition signal
			child.Transitioned.connect(on_child_transition)
	if initial_state:
		initial_state.enter()
		name_current_state = initial_state.name
		current_state = initial_state


# Call the update for the current state
func _process(delta):
	var s = current_state.name
	if current_state.name != name_current_state:
		on_child_transition(current_state, name_current_state)
	
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.physics_update(delta)

func on_child_transition(state : State, new_state_name : String):
	if state != current_state:
		return
	#Returns the corresponding value for the given key in the dictionary. If the key does not exist, returns default, or null if the parameter is omitted.
	var new_state : State = states.get(new_state_name.to_lower())
	name_current_state = new_state_name.to_lower()
	if new_state == null: return
	
	current_state.exit()
	current_state = new_state
	new_state.enter()
	
	
	pass
