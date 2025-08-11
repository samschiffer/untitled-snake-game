extends CharacterBody2D
class_name Locomotive

@export var independent: bool = true

signal collect_pickup
signal collect_health_pickup
signal collect_weapon_pickup
signal locomotive_hit

const FRICTION: float = 2
const WALL_COLLISION_SPEED = 90

var speed: float = 0
var max_speed
const MAX_SPEED_BASE = 600
const MAX_SPEED_BOOST = 800
var screen_size: Vector2
var angular_speed: float = PI

var boost_amount
const MAX_BOOST_AMOUNT = 100

var movement_locked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_speed = MAX_SPEED_BASE
	boost_amount = MAX_BOOST_AMOUNT
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Debug labels for speed and boost
	$SpeedLabel.text = str(speed)
	$BoostLabel.text = str(boost_amount)
	
	if independent:
		move(delta)


func move(delta: float):
	if not movement_locked:
		# Decrease speed based on friction
		speed -= FRICTION
		
		# Increase or decrease speed and add boost
		if Input.is_action_pressed("move_up"):
			if Input.is_action_pressed("boost") and boost_amount > 0:
				boost_amount -= 3
				speed += 15
				max_speed = MAX_SPEED_BOOST
			else: 
				if speed < MAX_SPEED_BASE:
					speed += 5
					max_speed = MAX_SPEED_BASE
				elif speed >= MAX_SPEED_BASE:
					speed -= 5
		if Input.is_action_pressed("move_down"):
			speed -= 5
		if not Input.is_action_pressed("boost"):
			boost_amount += 1
		
		# Clamp boost
		boost_amount = clamp(boost_amount, 0, MAX_BOOST_AMOUNT)
		
		# Clamp speed
		speed = clamp(speed, 0, max_speed)
		
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
