extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Train.move_to(Vector2(1000, 1000))
	
	# Set the camera limits
	var camera_buffer = 200
	$Camera2D.limit_left = $Room.position.x - camera_buffer
	$Camera2D.limit_top = $Room.position.y - camera_buffer
	$Camera2D.limit_right =  $Room.position.x + $Room.bounding_box.x + camera_buffer
	$Camera2D.limit_bottom =  $Room.position.y + $Room.bounding_box.y + camera_buffer
	
	# Open all the doors in the room
	$Room/DoorTop.open_for($Train/Locomotive)
	$Room/DoorLeft.open_for($Train/Locomotive)
	$Room/DoorBottom.open_for($Train/Locomotive)
	$Room/DoorRight.open_for($Train/Locomotive)


func _process(delta: float) -> void:
	$Camera2D.position = $Train/Locomotive.position
	if Input.is_action_just_pressed("test_action"):
		$Room/DoorTop.open_for($Train/Locomotive)
		$Room/DoorLeft.open_for($Train/Locomotive)
		$Room/DoorBottom.open_for($Train/Locomotive)
		$Room/DoorRight.open_for($Train/Locomotive)
		#
	#if Input.is_action_pressed("move_down"):
		#$Camera2D.position.y += 10
	#if Input.is_action_pressed("move_up"):
		#$Camera2D.position.y -= 10
	#if Input.is_action_pressed("move_left"):
		#$Camera2D.position.x -= 10
	#if Input.is_action_pressed("move_right"):
		#$Camera2D.position.x += 10


func _on_room_train_left_room(from_direction: String) -> void:
	#print("Train left room from ", from_direction)
	$Transition.fade()
	$Train/Locomotive.speed = 0
	go_to_next_room(from_direction)


func _on_room_train_entered_room(train: Train) -> void:
	$Train/Locomotive.speed = 600
	$Train/Locomotive.movement_locked = false
	await get_tree().create_timer(0.5).timeout
	$Room/DoorTop.close_for($Train/Locomotive)
	$Room/DoorLeft.close_for($Train/Locomotive)
	$Room/DoorBottom.close_for($Train/Locomotive)
	$Room/DoorRight.close_for($Train/Locomotive)


func go_to_next_room(from_direction: String):
	await get_tree().create_timer(2.0).timeout
	
	match from_direction:
		"top":
			# Go to the bottom
			$Train/Locomotive.rotation = 0
			$Train.move_to(Vector2($Room/ExitBottom.position.x, $Room/ExitBottom.position.y + 40))
			$Camera2D.position = $Room/ExitBottom.position
			$Camera2D.reset_smoothing()
		"left":
			# Go to the right
			$Train/Locomotive.rotation = (3 * PI) / 2.0
			$Train.move_to(Vector2($Room/ExitRight.position.x + 40, $Room/ExitRight.position.y))
			$Camera2D.position = $Room/ExitRight.position
			$Camera2D.reset_smoothing()
		"bottom":
			# Go to the top
			$Train/Locomotive.rotation = PI
			$Train.move_to(Vector2($Room/ExitTop.position.x, $Room/ExitTop.position.y - 40))
			$Camera2D.position = $Room/ExitTop.position
			$Camera2D.reset_smoothing()
		"right":
			# Go to the left
			$Train/Locomotive.rotation = PI / 2
			$Train.move_to(Vector2($Room/ExitLeft.position.x - 40, $Room/ExitLeft.position.y))
			$Camera2D.position = $Room/ExitLeft.position
			$Camera2D.reset_smoothing()
	
	$Room.check_for_train_entered($Train)
	$Train/Locomotive.show()
	$Train/Locomotive.speed = 450
	$Transition.unfade()


func _on_area_2d_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
