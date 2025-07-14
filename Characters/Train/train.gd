extends Node2D
class_name Train

@export var train_car_scene: PackedScene

signal died
signal health_changed

const MAX_TRAIN_CARS: float = 10
const TRAIN_CAR_BUFFER: float = 20 # The distance between each train car in the train

@onready var train_cars: Array[TrainCar] = []
var speed: float = 0
@export var max_health: float = 15
var health: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Health Label For Debugging
	$HealthLabel.text = String.num_int64(health)
	$HealthLabel.position = $Locomotive.position
	$HealthLabel.rotation = $Locomotive.rotation
	
	# Debugging spawning trains
	if Input.is_action_just_pressed("spawn_train"):
		print("F pressed")
		spawn_train()
		
	$Locomotive.move(delta)
	move_train_cars(delta)


# Move all of the train cars
func move_train_cars(delta):
	for index in train_cars.size():
		var next_car: Area2D
		if index == 0:
			next_car = $Locomotive
		else:
			next_car = train_cars[index - 1]
		
		var current_car: TrainCar = train_cars[index]
		var current_car_position: Vector2 = current_car.global_position
		var current_car_front: Vector2 = current_car.get_node("Front").global_position
		var next_car_back: Vector2 = next_car.get_node("Back").global_position
		
		# Find the direction this train car needs to move
		var movement_direction = next_car_back - current_car_position
		
		# Rotate car towards the next one in that direction
		if $Locomotive.speed > 0:
			current_car.rotation = movement_direction.angle() + PI / 2
		
		# Find where we are planning to move
		var planned_velocity: Vector2 = movement_direction.normalized() * $Locomotive.speed
		var planned_move: Vector2 = planned_velocity * delta
		
		# If we're going to overshoot the train car buffer with this move, just move up to the edge of the buffer
		var distance_to_next_car_back: Vector2 = next_car_back - current_car_front
		if planned_move.length() > distance_to_next_car_back.length() - TRAIN_CAR_BUFFER:
			planned_move = planned_move.normalized() * (distance_to_next_car_back.length() - TRAIN_CAR_BUFFER)
		
		current_car.position += planned_move


# Spawns a new TrainCar behind the last car in the train 
func spawn_train():
	# Do not spawn if the train has the max amount of train cars
	if train_cars.size() >= MAX_TRAIN_CARS:
		return
	
	# Create the new car and find the length from the center to the front
	var new_train_car = train_car_scene.instantiate()
	new_train_car.train_car_death.connect(_on_train_car_death)
	var car_center_to_front_len = (new_train_car.get_node("Front").position - new_train_car.position).length()
	
	# Get the last train car in the train
	var last_train_car: Area2D
	if train_cars.size() > 0:
		last_train_car = train_cars.back()
	else:
		last_train_car = $Locomotive
	var last_car_back = last_train_car.get_node("Back").global_position
	
	# Calculate where to spawn the new train and rotate to same as the last car
	var spawn_point = last_car_back - Vector2.UP.rotated(last_train_car.rotation) * (car_center_to_front_len + TRAIN_CAR_BUFFER)
	new_train_car.position = spawn_point
	new_train_car.rotation = last_train_car.rotation
	
	# Call deferred to avoid any side effects of adding nodes mid-frame
	call_deferred("add_train", new_train_car)


# Adds a new_train_car to the node tree and appends it to the list of train cars on the train
func add_train(new_train_car):
	add_child(new_train_car)
	train_cars.append(new_train_car)


# Moves the head of the train to a certain position
func move_to(pos: Vector2):
	$Locomotive.position = pos


# Handler for collecting a pickup
func _on_locomotive_collect_pickup() -> void:
	spawn_train()


func _on_locomotive_collect_health_pickup() -> void:
	health += 5
	health = clamp(health, 0, max_health)
	health_changed.emit()


func lose_back_car():
	var last_car: TrainCar = train_cars.pop_back()
	if last_car:
		last_car.queue_free()


func _on_locomotive_locomotive_hit() -> void:
	lose_back_car()
	health -= 5
	health_changed.emit()
	if health <= 0:
		hide()
		died.emit()
		queue_free()


func _on_train_car_death(train_car: Node):
	var train_car_hit_index: int = train_cars.find(train_car)
	remove_trains_after_index(train_car_hit_index)


func remove_trains_after_index(index):
	for train_car_index in train_cars.size():
		if train_car_index >= index:
			train_cars[train_car_index].queue_free()
	train_cars = train_cars.slice(0, index)
