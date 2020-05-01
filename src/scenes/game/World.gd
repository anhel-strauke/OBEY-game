extends Node2D


func _ready():
	# Assign player #0 with controller #0
	GameInput.set_gamepad_input_source(0, 0)
	# Assign player #1 with controller #1
	GameInput.set_gamepad_input_source(1, 1)
	
	# Alternative: assign keyboard controls (WSAD) to player #0
	# GameInput.set_keyboard_input_source(0)
	# Alternative: assign keyboard controls (↑↓←→) to player #1
	# GameInput.set_keyboard_input_source(1)
