extends Area2D
class_name Locomotive

@export var independent: bool = true

signal collect_pickup
signal locomotive_hit

const FRICTION: float = 2

var speed: float = 0
var screen_size: Vector2
var angular_speed: float = PI
var is_on_edge: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if independent:
		move(delta)


func move(delta: float):
	# Decrese speed based on friction
	speed -= FRICTION
	# Increase or decrese speed
	if Input.is_action_pressed("move_up"):
		speed += 5
	if Input.is_action_pressed("move_down"):
		speed -= 5
	# Clamp speed
	speed = clamp(speed, 0, 600)
	
	# Set angular speed proportional to speed and cap at PI
	angular_speed = PI * (speed / 400.0)
	angular_speed = clamp(angular_speed, 0, PI)
	
	# Change directions with left and right
	var direction: int = 0
	if Input.is_action_pressed("move_right"):
		direction = 1
	if Input.is_action_pressed("move_left"):
		direction = -1
	
	# Rotate the locomotive
	rotation += angular_speed * direction * delta
	
	# Calculate velocity based on speed and move the locomotive
	var velocity: Vector2 = Vector2.UP.rotated(rotation) * speed
	position += velocity * delta
	
	# Check if the locomotive is going out of bounds and if it is cut the speed to 0 
	if position.y < 0 or position.y > screen_size.y or position.x < 0 or position.x > screen_size.x:
		if is_on_edge == false:
			speed = 0
			is_on_edge = true
	else:
		is_on_edge = false
		
	position = position.clamp(Vector2.ZERO, screen_size)


func _on_area_entered(area: Area2D) -> void:
	if area is Shuriken:
		locomotive_hit.emit()
	if area is Pickup:
		area.hide()
		area.queue_free()
		collect_pickup.emit()
