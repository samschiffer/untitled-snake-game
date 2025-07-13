extends Area2D
#class_name Locomotive

@export var move_speed = 0
@export var independent: bool = true

signal collect_pickup
signal locomotive_hit
signal locomotive_hit_edge

var FRICTION = 2
var screen_size
var angular_speed = PI
var is_on_edge: bool = false
var previous_position
var actual_speed = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	previous_position = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if independent:
		move_locomotive(delta)


func move_locomotive(delta: float):
	var direction = 0
	
	move_speed -= FRICTION
	if move_speed < 0:
			move_speed = 0
	
	if Input.is_action_pressed("move_up"):
		move_speed += 5
		if move_speed > 600:
			move_speed = 600
	if Input.is_action_pressed("move_down"):
		move_speed -= 5
		if move_speed < 0:
			move_speed = 0
	
	# Set angular speed proportional to speed and cap at PI
	angular_speed = PI * (move_speed / 400.0)
	if angular_speed > PI:
		angular_speed = PI
	
	# Change directions with left and right
	if Input.is_action_pressed("move_right"):
		direction = 1
	if Input.is_action_pressed("move_left"):
		direction = -1
	
	rotation += angular_speed * direction * delta
	
	var velocity = Vector2.UP.rotated(rotation) * move_speed
	
	position += velocity * delta
	
	## Hitting the edge code
	if position.y < 0 or position.y > screen_size.y or position.x < 0 or position.x > screen_size.x:
		#print("Hit the edge")
		if is_on_edge == false:
			move_speed = 0
			#locomotive_hit_edge.emit()
			is_on_edge = true
	else:
		is_on_edge = false
		
		
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# Calculate actual speed moving
	var distance_traveled = position - previous_position 
	actual_speed = distance_traveled.length() / delta
	previous_position = position


func _on_body_entered(body: Node2D) -> void:
	#print(body)
	body.hide()
	body.queue_free()
	#print("Pickup received")
	collect_pickup.emit()
	pass # Replace with function body.


func _on_area_entered(area: Area2D) -> void:
	if area is Shuriken:
		#print("Locomotive hit")
		locomotive_hit.emit()
