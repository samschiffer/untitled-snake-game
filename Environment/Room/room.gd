extends Area2D
class_name Room

signal train_left_room(direction: String)
signal train_entered_room(train: Train)

@onready var bounding_box

# Entering and leaving variables
var leaving_train: Train
var entering_train: Train
var check_for_train_leaving: bool = false
var train_left: bool = false
var train_leave_direction: String
var check_for_train_entering: bool = false
var train_entered: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_bounding_box()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if check_for_train_leaving:
		if is_train_out_of_room_completely(leaving_train) and not train_left:
			train_left_room.emit(train_leave_direction)
			train_left = true
			check_for_train_leaving = false
	
	if check_for_train_entering:
		if is_train_in_room_completely(entering_train) and not train_entered:
			train_entered_room.emit(entering_train)
			train_entered = true
			check_for_train_entering = false


func get_bounding_box():
	var min_x = INF
	var max_x = -INF
	
	var min_y = INF
	var max_y = -INF
	
	var polygon_points = $Floor.polygon
	var scaled_points = polygon_points * $Floor.global_transform
	
	for point in scaled_points:
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
		
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		
	bounding_box = Vector2(max_x - min_x, max_y - min_y)	

## Checking train in or out of room

func is_train_in_room_completely(train: Train):
	if not overlaps_body(train.get_node("Locomotive")):
		return false
	for train_car in train.train_cars:
		if not overlaps_area(train_car):
			return false
	return true


func is_train_out_of_room_completely(train: Train):
	if overlaps_area(train.get_node("Locomotive")):
		return false
	for train_car in train.train_cars:
		if overlaps_area(train_car):
			return false
	return true


func check_for_train_entered(train: Train):
	entering_train = train
	train_entered = false
	check_for_train_entering = true
	
	
########################
## Handle Exit Actions
########################

## Top Exit
func _on_exit_top_body_entered(body: Node2D) -> void:
	if body.position.y > $ExitTop.position.y and body is Locomotive:
		body.hide()
		check_for_train_leaving = true
		leaving_train = body.get_parent()
		train_leave_direction = "top"
	else: 
		body.show()
		check_for_train_leaving = false


func _on_exit_top_area_entered(area: Area2D) -> void:
	if area.position.y > $ExitTop.position.y and area is TrainCar:
		area.hide()
	else: 
		area.show()


func _on_exit_top_body_exited(body: Node2D) -> void:
	if body is Locomotive and body.position.y < $ExitTop.position.y:
		body.movement_locked = true
		body.rotation = 0
		body.speed = max(200, body.speed)
	else:
		train_left = false


## Left Exit
func _on_exit_left_body_entered(body: Node2D) -> void:
	if body.position.x > $ExitLeft.position.x and body is Locomotive:
		body.hide()
		check_for_train_leaving = true
		leaving_train = body.get_parent()
		train_leave_direction = "left"
	else: 
		body.show()
		check_for_train_leaving = false


func _on_exit_left_area_entered(area: Area2D) -> void:
	if area.position.x > $ExitLeft.position.x and area is TrainCar:
		area.hide()
	else: 
		area.show()


func _on_exit_left_body_exited(body: Node2D) -> void:
	if body is Locomotive and body.position.x < $ExitLeft.position.x:
		body.movement_locked = true
		body.rotation = 3 * PI / 2
		body.speed = max(200, body.speed)
	else:
		train_left = false


## Bottom Exit
func _on_exit_bottom_body_entered(body: Node2D) -> void:
	if body.position.y < $ExitBottom.position.y and body is Locomotive:
		body.hide()
		check_for_train_leaving = true
		leaving_train = body.get_parent()
		train_leave_direction = "bottom"
	else: 
		body.show()
		check_for_train_leaving = false


func _on_exit_bottom_area_entered(area: Area2D) -> void:
	if area.position.y < $ExitBottom.position.y and area is TrainCar:
		area.hide()
	else: 
		area.show()


func _on_exit_bottom_body_exited(body: Node2D) -> void:
	if body is Locomotive and body.position.y > $ExitBottom.position.y:
		body.movement_locked = true
		body.rotation = PI
		body.speed = max(200, body.speed)
	else:
		train_left = false


## Right Exit
func _on_exit_right_body_entered(body: Node2D) -> void:
	if body.position.x < $ExitRight.position.x and body is Locomotive:
		body.hide()
		check_for_train_leaving = true
		leaving_train = body.get_parent()
		train_leave_direction = "right"
	else: 
		body.show()
		check_for_train_leaving = false


func _on_exit_right_area_entered(area: Area2D) -> void:
	if area.position.x < $ExitRight.position.x and area is TrainCar:
		area.hide()
	else: 
		area.show()


func _on_exit_right_body_exited(body: Node2D) -> void:
	if body is Locomotive and body.position.x > $ExitRight.position.x:
		body.movement_locked = true
		body.rotation = PI / 2
		body.speed = max(200, body.speed)
	else:
		train_left = false
