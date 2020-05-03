extends "res://gfx/scenes/RenderableLight.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	intensity = 0
	$AnimationPlayer.play("Flash")
	$Sprite.rotation = rand_range(-PI, PI)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
