extends Node2D


func _process(delta):
	update()

func _draw():
	for spot in get_parent().hiding_spots:
		draw_rect(Rect2(spot.position - global_position, Vector2(10,10)), Color(1,0,0,1))

