extends Node

@onready var room: Room

var special_room_scene: PackedScene = preload("res://Environment/SpecialRoom.tscn")
var pickup_scene: PackedScene = preload("res://Objects/Pickup/pickup.tscn")
var camera_buffer = 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	room = $Room
	room.train_left_room.connect(_on_room_train_left_room)
	room.train_entered_room.connect(_on_room_train_entered_room)
	
	$Train.move_to(Vector2(1000, 1000))
	
	# Set the camera limits
	
	$Camera2D.limit_left = room.position.x - camera_buffer
	$Camera2D.limit_top = room.position.y - camera_buffer
	$Camera2D.limit_right =  room.position.x + room.bounding_box.x + camera_buffer
	$Camera2D.limit_bottom =  room.position.y + room.bounding_box.y + camera_buffer
	
	# Open all the doors in the room
	room.door_top.open_for($Train/Locomotive)
	room.door_left.open_for($Train/Locomotive)
	room.door_bottom.open_for($Train/Locomotive)
	room.door_right.open_for($Train/Locomotive)


func _process(delta: float) -> void:
	$Camera2D.position = $Train/Locomotive.position
	if Input.is_action_just_pressed("test_action"):
		#spawn_pickup()
		room.door_top.open_for($Train/Locomotive)
		room.door_left.open_for($Train/Locomotive)
		room.door_bottom.open_for($Train/Locomotive)
		room.door_right.open_for($Train/Locomotive)
		
	if Input.is_key_pressed(KEY_DOWN):
		$Camera2D.position.y += 10
	if Input.is_key_pressed(KEY_UP):
		$Camera2D.position.y -= 10
	if Input.is_key_pressed(KEY_LEFT):
		$Camera2D.position.x -= 10
	if Input.is_key_pressed(KEY_RIGHT):
		$Camera2D.position.x += 10


func spawn_pickup():
	var spawn_point: Vector2 = get_random_point_in_room()
	var new_pickup: Area2D = pickup_scene.instantiate()
	new_pickup.position = spawn_point
	add_child(new_pickup)


func get_random_point_in_room():
	var room_width = room.bounding_box.x
	var room_height = room.bounding_box.y
	var spawn_point_in_room = false
	var rand_x: float
	var rand_y: float
	var tries = 0
	
	var room_floor: Polygon2D = room.floor
	var room_floor_polygon: PackedVector2Array = room_floor.polygon
	var transformed_polygon_points = []
	for point_local in room_floor_polygon:
		var point_global = room_floor.to_global(point_local)
		transformed_polygon_points.append(point_global)
		
	while not spawn_point_in_room:
		rand_x = randf_range(60.0, room_width - 60.0)
		rand_y = randf_range(60.0, room_height - 60.0)
		spawn_point_in_room = Geometry2D.is_point_in_polygon(Vector2(rand_x, rand_y), transformed_polygon_points)
		tries += 1
		if tries > 500:
			print("Timed out: could not find point in room") # TODO Add better error handling
			spawn_point_in_room = true
	
	return Vector2(rand_x, rand_y)

func _on_room_train_left_room(from_direction: String) -> void:
	#print("Train left room from ", from_direction)
	$Transition.fade()
	$Train/Locomotive.speed = 0
	go_to_next_room(from_direction)


func _on_room_train_entered_room(train: Train) -> void:
	$Train/Locomotive.speed = 600
	$Train/Locomotive.movement_locked = false
	await get_tree().create_timer(0.5).timeout
	room.door_top.close_for($Train/Locomotive)
	room.door_left.close_for($Train/Locomotive)
	room.door_bottom.close_for($Train/Locomotive)
	room.door_right.close_for($Train/Locomotive)


func go_to_next_room(from_direction: String):
	await get_tree().create_timer(2.0).timeout
	
	## Going to a new room ##
	room.queue_free()
	var special_room = special_room_scene.instantiate()
	$Camera2D.add_sibling(special_room)
	room = special_room
	
	$Camera2D.limit_left = room.position.x - camera_buffer
	$Camera2D.limit_top = room.position.y - camera_buffer
	$Camera2D.limit_right =  room.position.x + room.bounding_box.x + camera_buffer
	$Camera2D.limit_bottom = room.position.y + room.bounding_box.y + camera_buffer
	
	room.train_left_room.connect(_on_room_train_left_room)
	room.train_entered_room.connect(_on_room_train_entered_room)
	room.door_top.open_for($Train/Locomotive)
	room.door_left.open_for($Train/Locomotive)
	room.door_bottom.open_for($Train/Locomotive)
	room.door_right.open_for($Train/Locomotive)
	#######################
	
	var train_entry
	match from_direction:
		"top":
			train_entry = room.entry_bottom
			# Go to the bottom
			#$Train/Locomotive.rotation = room.entry_bottom.rotation
			#$Train.move_to(room.entry_bottom.position)
			#$Camera2D.position = room.entry_bottom.position
			#$Camera2D.reset_smoothing()
		"left":
			train_entry = room.entry_right
			# Go to the right
			#$Train/Locomotive.rotation = room.entry_right.rotation
			#$Train.move_to(room.entry_right.position)
			#$Camera2D.position = room.door_right.position
			#$Camera2D.reset_smoothing()
		"bottom":
			train_entry = room.entry_top
			# Go to the top
			#$Train/Locomotive.rotation = room.entry_top.rotation
			#$Train.move_to(room.entry_top.position)
			#$Camera2D.position = room.door_top.position
			#$Camera2D.reset_smoothing()
		"right":
			train_entry = room.entry_left
			# Go to the left
			#$Train/Locomotive.rotation = room.entry_left.rotation
			#$Train.move_to(room.entry_left.position)
			#$Camera2D.position = room.door_left.position
			#$Camera2D.reset_smoothing()
	
	# Go to the entry point
	$Train/Locomotive.rotation = train_entry.rotation
	$Train.move_to(train_entry.position)
	$Camera2D.position = train_entry.position
	$Camera2D.reset_smoothing()
	
	
	room.check_for_train_entered($Train)
	$Train/Locomotive.show()
	$Train/Locomotive.speed = 450
	$Transition.unfade()


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.


func _on_new_door_object_entered(node: Node) -> void:
	print("Object Entered ", node)


func _on_new_door_object_exited(node: Node) -> void:
	print("Object Exited ", node)
