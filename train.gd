extends Node2D
class_name Train

@export var train_car_scene: PackedScene

signal died
signal health_changed

@onready var train_cars = []
#var removed_trains = []
var speed = 0
var health: float = 15
var car_link_buffer = 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Debugging Mouse Input
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("Mouse position", get_viewport().get_mouse_position())
	
	## Health Label Debugging
	$HealthLabel.text = String.num_int64(health)
	$HealthLabel.position = $Locomotive.position
	$HealthLabel.rotation = $Locomotive.rotation
		
	if Input.is_action_just_pressed("spawn_train"):
		print("F pressed")
		spawn_train()
		
	speed -= 2
	if speed < 0:
		speed = 0
	
	# Increase or decrese speed
	if Input.is_action_pressed("move_up"):
		speed += 5
		if speed > 600:
			speed = 600
	if Input.is_action_pressed("move_down"):
		speed -= 5
		if speed < 0:
			speed = 0
	
	$Locomotive.speed = speed


func move_train_cars(delta):
	for index in train_cars.size():
		var next_car
		if index == 0:
			next_car = $Locomotive
		else:
			next_car = train_cars[index - 1]
		
		var current_car = train_cars[index]
		var current_car_position = current_car.global_position
		var front_of_current_car = current_car.get_node("Front").global_position
		
		var back_of_next_car = next_car.get_node("Back").get_global_position()
		
		## Implementation 2
		var movement_direction = back_of_next_car - current_car_position
		
		# Rotate car towards the next one
		if speed > 0:
			current_car.rotation = movement_direction.angle() + PI / 2
		
		
		var velocity = movement_direction.normalized() * speed
		var planned_move = velocity * delta
		
		var distance_to_back_of_next_car = back_of_next_car - front_of_current_car
		# If we're going to overshoot the buffer with this move, just move up to the edge of the buffer
		if planned_move.length() > distance_to_back_of_next_car.length() - car_link_buffer:
			planned_move = planned_move.normalized() * (distance_to_back_of_next_car.length() - car_link_buffer)
		
		current_car.position += planned_move
		
		## Implementation 1
		#var movement_direction = back_of_next_car - current_car_position
		#
		#var velocity
		#var car_gap_distance = back_of_next_car - current_car.get_node("Front").global_position
		#if car_gap_distance.length() > car_link_buffer:
			#velocity = movement_direction.normalized() * speed
			#current_car.times_too_close = 0
		#else:
			#current_car.times_too_close += 1
			#if current_car.times_too_close > 20:
				#velocity = Vector2.ZERO
			#else:
				#velocity = current_car.current_velocity * 0.6
			#
			##velocity = Vector2.ZERO
		#
		#current_car.current_velocity = Vector2(velocity.x, velocity.y)
			#
		#current_car.position += velocity * delta
		#
		#if speed > 0:
			#current_car.rotation = movement_direction.angle() + PI / 2
			

#func get_back_of_car(train_car: Area2D):
	#var head_size = train_car.get_node("CollisionShape2D").shape.get_rect().size
	#var global_position = train_car.position
	#var bottom_of_head = global_position - Vector2.UP.rotated(train_car.rotation) * (head_size.y / 2)
	#return bottom_of_head


#func get_front_of_car(train_car: Area2D):
	#var head_size = train_car.get_node("CollisionShape2D").shape.get_rect().size
	#var global_position = train_car.position
	#var top_of_head = global_position + Vector2.UP.rotated(train_car.rotation) * (head_size.y / 2)
	#return top_of_head


#func get_car_length(train_car: Area2D):
	#return train_car.get_node("CollisionShape2D").shape.get_rect().size.y

func spawn_train():
	if train_cars.size() >= 10:
		return
	var new_train_car = train_car_scene.instantiate()
	new_train_car.train_car_hit.connect(_on_train_car_hit)
	var car_offset = (new_train_car.get_node("Front").position - new_train_car.position).length()
	var last_train_car
	if train_cars.size() > 0:
		last_train_car = train_cars.back()
	else:
		last_train_car = $Locomotive
	
	var back_of_last_car = last_train_car.get_node("Back").global_position
	var spawn_point = back_of_last_car - Vector2.UP.rotated(last_train_car.rotation) * (car_offset + car_link_buffer)
	new_train_car.position = spawn_point
	new_train_car.rotation = last_train_car.rotation
	call_deferred("add_train", new_train_car)


func add_train(new_train_car):
	add_child(new_train_car)
	train_cars.append(new_train_car)
	

func move_to(pos: Vector2):
	$Locomotive.position = pos


func _on_locomotive_collect_pickup() -> void:
	spawn_train()
	pass # Replace with function body.


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
	var train_car_hit_index = train_cars.find(train_car)
	remove_trains_after_index(train_car_hit_index)


func remove_trains_after_index(index):
	for train_car_index in train_cars.size():
		if train_car_index >= index:
			#removed_trains.append(train_cars[train_car_index])
			train_cars[train_car_index].queue_free()
	train_cars = train_cars.slice(0, index)


func _on_locomotive_locomotive_hit_edge() -> void:
	speed = 0
	pass # Replace with function body.


func _on_locomotive_locomotive_moved(delta: float) -> void:
	move_train_cars(delta)
	pass # Replace with function body.
