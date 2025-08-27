extends Node2D
class_name Door

signal object_exited(node: Node)
signal object_entered(node: Node)

var inside_buffer: Array = []
var outside_buffer: Array = []

var is_open: bool = false

func open_for(body: Node):
	is_open = true
	$PhysicalDoor/Polygon2D.color = Color(0.0, 0.6, 0.2)
	$PhysicalDoor.add_collision_exception_with(body)


func close_for(body: Node):
	is_open = false
	$PhysicalDoor/Polygon2D.color = Color(0.8, 0, 0)
	$PhysicalDoor.remove_collision_exception_with(body)

func _on_outside_area_entered(area: Area2D) -> void:
	if area in inside_buffer:
		object_exited.emit(area)
		inside_buffer.erase(area)
	else:
		outside_buffer.append(area)


func _on_outside_body_entered(body: Node2D) -> void:
	if body in inside_buffer:
		object_exited.emit(body)
		inside_buffer.erase(body)
	else:
		outside_buffer.append(body)


func _on_inside_area_entered(area: Area2D) -> void:
	if area in outside_buffer:
		object_entered.emit(area)
		outside_buffer.erase(area)
	else:
		inside_buffer.append(area)


func _on_inside_body_entered(body: Node2D) -> void:
	if body in outside_buffer:
		object_entered.emit(body)
		outside_buffer.erase(body)
	else:
		inside_buffer.append(body)
