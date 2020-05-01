extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var nul: Vector2 = Vector2()
var aidriver

# Called when the node enters the scene tree for the first time.
func _ready():
	aidriver = get_parent().get_node("Driver")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()	
	
func _draw():
	$StateLabel.text = aidriver.get_stack_description()
	draw_line(nul, aidriver.get_velocity_vector()*100.0, Color(1,1,1), 3)
