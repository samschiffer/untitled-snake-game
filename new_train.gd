extends Node2D
#class_name Train

@export var train_car_scene: PackedScene

signal died
signal health_changed

@onready var train_cars = [$TrainCar]
#var removed_trains = []
var speed = 0
var health: float = 15
var print_distance_between_cars = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Speed.text = str(speed)
	$EffectiveSpeed.text = str($New_Locomotive.actual_speed)
	
	## Mouse Click For Debugging
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("Mouse position", get_viewport().get_mouse_position())
	
	## Health Label Code
	#$HealthLabel.text = String.num_int64(health)
	#$HealthLabel.position = $Locomotive.position
	#$HealthLabel.rotation = $Locomotive.rotation


	if Input.is_action_just_pressed("spawn_train"):
		print("F pressed")
		spawn_train()
	
	$New_Locomotive.move_locomotive(delta)
	move_train_cars(delta)

#func _on_locomotive_locomotive_moved(delta: float) -> void:
	#move_train_cars(delta)
	#pass # Replace with function body.

func move_train_cars(delta):
	for index in train_cars.size():
		var next_car
		if index == 0:
			next_car = $New_Locomotive
		else:
			next_car = train_cars[index - 1]
		
		var current_car = train_cars[index]
		var current_car_position = current_car.position
		var back_of_next_car: Vector2 = next_car.get_node("Back").global_position
		var movement_direction = back_of_next_car - current_car_position
		
		
		var rotation_direction = next_car.global_position - current_car.global_position
		
		
		
		## Rotation
		
		## Implementation 1
		#var current_direction: Vector2 = current_car.get_node("Front").global_position - current_car.global_position
		#var turn_angle = snapped(current_direction.angle_to(movement_direction), 0.01)
		#
		#var direction
		#if turn_angle > 0:
			## turn right
			#direction = 1
		#elif turn_angle < 0:
			## turn left
			#direction = -1
		#else:
			## don't turn
			#direction = 0
		#
		## Make angular speed proportional to actual speed of locomotive
		#var angular_speed = PI * ($New_Locomotive.actual_speed / 400.0)
		#if angular_speed > PI:
			#angular_speed = PI
			#
		#var turn_with_speed = angular_speed * direction * delta
		## Make sure not to overturn
		#var actual_turn_amount = min(turn_with_speed, turn_angle) 
		#current_car.rotation += actual_turn_amount
		
		## Implementation 2
		#var current_car_vector: Vector2 = current_car.get_node("Front").global_position - current_car.global_position
		#var next_car_vector: Vector2 = next_car.global_position - back_of_next_car
		#
		#var turn_angle = snapped(current_car_vector.angle_to(next_car_vector), 0.01)
		#
		#var direction
		#if turn_angle > 0:
			## turn right
			#direction = 1
		#elif turn_angle < 0:
			## turn left
			#direction = -1
		#else:
			## don't turn
			#direction = 0
		#
		## Make angular speed proportional to actual speed of locomotive
		#var angular_speed = PI * ($New_Locomotive.actual_speed / 600.0)
		#if angular_speed > PI:
			#angular_speed = PI
			#
		#var turn_with_speed = angular_speed * direction * delta
		## Make sure not to overturn
		#var actual_turn_amount = min(turn_with_speed, turn_angle) 
		#current_car.rotation += actual_turn_amount
		
		
		### Simple solution
		#current_car.rotation = movement_direction.angle() + PI / 2
		
		var current_car_vector: Vector2 = current_car.get_node("Front").global_position - current_car.global_position
		var next_car_vector: Vector2 = next_car.global_position - back_of_next_car
		
		var turn_angle = snapped(current_car_vector.angle_to(next_car_vector), 0.01)
		
		#var target_rotation = rotation_direction.angle() + PI / 2
		var speed_factor = $New_Locomotive.actual_speed / 600.0
		current_car.rotation += ((turn_angle) / 10) * speed_factor
		
		#current_car.rotation = rotation_direction.angle() + PI / 2
		
		## Move Car
		var current_car_front = current_car.get_node("Front").global_position
		var movement_distance = back_of_next_car - current_car_front
		current_car.position += movement_distance
		
		#if movement_distance.x != 0 or movement_distance.y != 0:
			#current_car.rotation = movement_distance.angle() + PI / 2
	
	if print_distance_between_cars:
		var distance = $New_Locomotive.get_node("Back").global_position - $TrainCar.get_node("Front").global_position 
		print("Distance between cars: ", distance.length())
		print_distance_between_cars = false

## Spawn Train
func spawn_train():
	if train_cars.size() >= 10:
		return
	var new_train_car = train_car_scene.instantiate()
	#new_train_car.train_car_hit.connect(_on_train_car_hit) ## TODO: Add in the hit signal here
	var last_train_car
	if train_cars.size() > 0:
		last_train_car = train_cars.back()
	else:
		last_train_car = $New_Locomotive
	
	var back_of_last_car = last_train_car.get_node("Back").global_position
	var top_of_car_to_middle = new_train_car.get_node("Front").position - new_train_car.position
	var spawn_point = back_of_last_car - top_of_car_to_middle
	new_train_car.position = spawn_point
	new_train_car.rotation = last_train_car.rotation
	call_deferred("add_train", new_train_car)


func add_train(new_train_car):
	add_child(new_train_car)
	train_cars.append(new_train_car)
	

func move_to(pos: Vector2):
	$New_Locomotive.position = pos


func _on_locomotive_collect_pickup() -> void:
	#spawn_train()
	pass # Replace with function body.


func _on_decay_timer_timeout() -> void:
	#lose_car()
	pass

func lose_back_car():
	var decayed_train = train_cars.pop_back()
	if decayed_train:
		decayed_train.queue_free()
	else:
		print("No cars you lose!")


func _on_locomotive_locomotive_hit() -> void:
	lose_back_car()
	health -= 5
	health_changed.emit()
	if health <= 0:
		hide()
		died.emit()
		queue_free()
	pass # Replace with function body.

func _on_train_car_hit(train_car: Node):
	#print("Train Car Hit")
	var train_car_hit_index = train_cars.find(train_car)
	#print("Train Car No.: ", train_car_hit_index)
	remove_trains_after_index(train_car_hit_index)
	#print("Removed Trains: ", removed_trains)
	#for train in removed_trains:
		#print("Train: ", train)
		#print("Is queued for freeing: ", train.is_queued_for_deletion())
	#removed_trains.clear()


func remove_trains_after_index(index):
	for train_car_index in train_cars.size():
		if train_car_index >= index:
			#removed_trains.append(train_cars[train_car_index])
			train_cars[train_car_index].queue_free()
	train_cars = train_cars.slice(0, index)


func _on_locomotive_locomotive_hit_edge() -> void:
	speed = 0
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	print_distance_between_cars = true
	pass # Replace with function body.
