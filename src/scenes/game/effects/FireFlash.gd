extends "res://gfx/scenes/RenderableLight.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	intensity = 0
	$AnimationPlayer.play("Flash")
	print("flash ready: ", light_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
