extends CharacterBody2D
class_name Locomotive

@export var independent: bool = true

signal collect_pickup
signal collect_health_pickup
signal locomotive_hit

const FRICTION: float = 2
const WALL_COLLISION_SPEED = 90

var speed: float = 0
var screen_size: Vector2
var angular_speed: float = PI

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
	
	# Calculate velocity based on speed and move the locomotive checking for collisions
	var velocity: Vector2 = Vector2.UP.rotated(rotation) * speed
	var collision = move_and_collide(velocity * delta)

	# Check if the locomotive is colliding with something and if it is cut the speed to WALL_COLLISION_SPEED 
	if collision != null:
		speed = WALL_COLLISION_SPEED
