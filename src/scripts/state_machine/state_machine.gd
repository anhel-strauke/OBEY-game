extends Node
# Base interface for a generic state machine.
# It handles initializing, setting the machine active or not
# delegating _physics_process, _input calls to the State nodes,
# and changing the current/active state.
# See the PlayerV2 scene for an example on how to use it.

signal state_changed(current_state)

# You should set a starting node from the inspector or on the node that inherits
# from this state machine interface. If you don't, the game will default to
# the first state in the state machine's children.
export(NodePath) var start_state
var states_map = {}

var states_stack = []
var current_state = null
var _active = false setget set_active
var consumed_last = true

func _ready():
	if not start_state:
		start_state = get_child(0).get_path()
	for child in get_children():
		child.connect("finished", self, "_change_state")
		child.connect("stack_invalid", self, "_reset_to_state")
	initialize(start_state)


func initialize(initial_state):
	set_active(true)
	states_stack.push_front(get_node(initial_state))
	current_state = states_stack[0]
	current_state.enter()

func set_active(value):
	_active = value
	#set_physics_process(value)
	#set_process_input(value)
	if not _active:
		states_stack = []
		current_state = null

func get_stack_description():
	var descr = ""
	for state in states_stack:
		descr += state.get_state_description()
		descr += "\n"
	return descr

#func _input(event):
#	current_state.handle_input(event)


#func _physics_process(delta):
func _process(delta):
	consumed_last = current_state.update(delta)
	if !consumed_last and states_stack.size() > 1:
		states_stack[1].update(delta)


func _on_animation_finished(anim_name):
	if not _active:
		return
	current_state._on_animation_finished(anim_name)


func _change_state(state_name):
	if not _active:
		return
	current_state.exit()

	if state_name == "previous":
		states_stack.pop_front()
		 # fixme: actually, this should never happen, but there's a hole in logic that leads to a Think state exit somewhere
		if states_stack.empty():
			initialize(start_state)
	else:
		states_stack[0] = states_map[state_name]

	current_state = states_stack[0]
	emit_signal("state_changed", current_state)

	if state_name != "previous":
		current_state.enter()

func _reset_to_state(state_name):
	if not _active:
		return
	var returnCount = 0	
	for state in states_stack:
		if states_map[state_name] != state:
			returnCount += 1
		else:
			break	
	
	for i in range(0, returnCount):
		states_stack.pop_front().exit()
	
	if(states_stack.empty()):
		_change_state(state_name)
	else:
		current_state = states_stack[0]
		emit_signal("state_changed", current_state)
