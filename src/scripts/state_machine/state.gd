extends Node
# Base interface for all states: it doesn't do anything by itself,
# but forces us to pass the right arguments to the methods below
# and makes sure every State object had all of these methods.

# warning-ignore:unused_signal
signal finished(next_state_name)
signal stack_invalid()

# Initialize the state. E.g. change the animation.
func enter():
	pass


# Clean up the state. Reinitialize values like a timer.
func exit():
	pass


#func handle_input(_event):
#	pass


func update(_delta) -> bool:
	return true


func _on_animation_finished(_anim_name):
	pass

func get_state_description():
	return "No-op state"
