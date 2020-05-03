extends Polygon2D

export(NodePath) var navigation_polygon_path
onready var navigation_polygon = get_node(navigation_polygon_path)
export(int) var outline_number = 0

func _process(delta):
	if outline_number < navigation_polygon.get_navigation_polygon().get_outline_count():
		color = Color( 0, 1, 0, 0.4 )
		var outline = navigation_polygon.get_navigation_polygon().get_outline(outline_number)
		set_polygon(outline)
	else:
		color = Color( 1, 1, 1, 0 )
