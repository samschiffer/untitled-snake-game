extends Area2D
class_name Room

signal train_left_room(direction: String)
signal train_entered_room(train: Train)

@onready var bounding_box

@export var door_top: Door
@export var door_right: Door
@export var door_bottom: Door
@export var door_left: Door

@export var entry_top: Marker2D
@export var entry_right: Marker2D
@export var entry_bottom: Marker2D
@export var entry_left: Marker2D

@export var floor: Polygon2D


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
	connect_door_signals()


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


func connect_door_signals():
	# Top Door Signals
	door_top.object_entered.connect(_on_door_top_object_entered)
	door_top.object_exited.connect(_on_door_top_object_exited)
	
	# Right Door Signals
	door_right.object_entered.connect(_on_door_right_object_entered)
	door_right.object_exited.connect(_on_door_right_object_exited)
	
	# Bottom Door Signals
	door_bottom.object_entered.connect(_on_door_bottom_object_entered)
	door_bottom.object_exited.connect(_on_door_bottom_object_exited)
	
	# Left Door Signals
	door_left.object_entered.connect(_on_door_left_object_entered)
	door_left.object_exited.connect(_on_door_left_object_exited)


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

## Closing or opening doors

func close_all_doors_for(body: Node):
	door_bottom.close_for(body)
	door_right.close_for(body)
	door_top.close_for(body)
	door_left.close_for(body)


func open_all_doors_for(body: Node):
	door_bottom.open_for(body)
	door_right.open_for(body)
	door_top.open_for(body)
	door_left.open_for(body)


########################
## Handle Exit Actions
########################

## Top Exit
func _on_door_top_object_entered(node: Node) -> void:
	node.show()
	check_for_train_leaving = false
	train_left = false


func _on_door_top_object_exited(node: Node) -> void:
	node.hide()
	if node is Locomotive:
		# Handle leaving train checks
		check_for_train_leaving = true
		leaving_train = node.get_parent()
		train_leave_direction = "top"
		# Lock movement of train out of room
		node.movement_locked = true
		node.rotation = 0
		node.speed = max(200, node.speed)


## Right Exit
func _on_door_right_object_entered(node: Node) -> void:
	node.show()
	check_for_train_leaving = false
	train_left = false


func _on_door_right_object_exited(node: Node) -> void:
	node.hide()
	if node is Locomotive:
		# Handle leaving train checks
		check_for_train_leaving = true
		leaving_train = node.get_parent()
		train_leave_direction = "right"
		# Lock movement of train out of room
		node.movement_locked = true
		node.rotation = PI / 2
		node.speed = max(200, node.speed)


## Bottom Exit
func _on_door_bottom_object_entered(node: Node) -> void:
	node.show()
	check_for_train_leaving = false
	train_left = false


func _on_door_bottom_object_exited(node: Node) -> void:
	node.hide()
	if node is Locomotive:
		# Handle leaving train checks
		check_for_train_leaving = true
		leaving_train = node.get_parent()
		train_leave_direction = "bottom"
		# Lock movement of train out of room
		node.movement_locked = true
		node.rotation = PI
		node.speed = max(200, node.speed)


## Left Exit
func _on_door_left_object_entered(node: Node) -> void:
	node.show()
	check_for_train_leaving = false
	train_left = false
	
func _on_door_left_object_exited(node: Node) -> void:
	node.hide()
	if node is Locomotive:
		# Handle leaving train checks
		check_for_train_leaving = true
		leaving_train = node.get_parent()
		train_leave_direction = "left"
		# Lock movement of train out of room
		node.movement_locked = true
		node.rotation = 3 * PI / 2
		node.speed = max(200, node.speed)
