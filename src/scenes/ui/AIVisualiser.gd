extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var nul: Vector2 = Vector2()
var aidriver

# Called when the node enters the scene tree for the first time.
func _ready():
	aidriver = get_parent().get_node("Driver")
	set_process_input(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()	
	
func _draw():
	$StateLabel.text = aidriver.get_stack_description()
	draw_line(nul, aidriver.get_velocity_vector().normalized()*100.0, Color(1,1,1), 3)
	var drawAnchor = nul - global_position
	var prevPoint = null
	for point in aidriver.get_path():
		if prevPoint != null:
			draw_line(prevPoint - global_position, point - global_position, Color(1,1,0), 3)
		prevPoint = point

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_PLUS:
			aidriver.incMockTTK()
		if event.scancode == KEY_EQUAL and event.shift:
			aidriver.incMockTTK()
		if event.scancode == KEY_MINUS:
			aidriver.decMockTTK()
