extends StaticBody2D
class_name Door

var is_open: bool = false

func open_for(body: Node):
	is_open = true
	$Polygon2D.color = Color(0.0, 0.6, 0.2)
	add_collision_exception_with(body)


func close_for(body: Node):
	is_open = false
	$Polygon2D.color = Color(0.8, 0, 0)
	remove_collision_exception_with(body)
