extends Area2D
class_name Wanderer

signal died

@export var shoot_cooldown := 3
@export var health := 7
var bullet_scene: PackedScene = load("res://Objects/Shuriken/shuriken.tscn")

var colliding_cars: Array[CollisionObject2D] = []
var speed: float = 0
const SLIDE_SPEED: float = 400

# Movement vars
var should_move: bool = false
var movement_vector: Vector2

# Rotation vars
var should_rotate: bool = false
var start_rotation: float
var desired_rotation: float
var elapsed: float = 0

# Shooting vars
var can_shoot: bool = true
var should_shoot: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootTimer.wait_time = shoot_cooldown
	$ShootTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update debug labels
	$ShootTimeLabel.text = str(snapped($ShootTimer.time_left, 0.1))
	$HealthLabel.text = str(health)
	
	# Unpause the shoot timer if there are no cars attacking (colliding with) the enemy
	if colliding_cars.size() == 0:
		$ShootTimer.set_paused(false)
	
	if should_move:
		can_shoot = false
		move(delta)
	
	if should_rotate:
		rotate_wanderer(delta)
	
	if should_shoot:
		attempt_shot()
	
	if Input.is_action_just_pressed("test_action"):
		print(ray_is_colliding_with_wall())

#################################
## Movement
#################################

func _on_move_timer_timeout() -> void:
	new_random_movement()


func new_random_movement():
	# Randomize the new direction to move
	var new_direction
	new_direction = randomize_move()
	while ray_is_colliding_with_wall():
		new_direction = randomize_move()
	
	# Find the movement vector, reset the speed, and tell wanderer to move
	movement_vector =  $RayCast2D.target_position.rotated(rotation + $RayCast2D.rotation)
	speed = SLIDE_SPEED
	should_move = true
	
	# Find the desired rotation and set up vars for rotation lerp
	start_rotation = rotation
	desired_rotation = fposmod(deg_to_rad(new_direction), TAU)
	elapsed = 0
	should_rotate = true


func randomize_move():
	var new_direction = randf_range(45.0, 315.0)
	$RayCast2D.rotation = deg_to_rad(new_direction)
	$RayCast2D.force_raycast_update()
	return new_direction


func ray_is_colliding_with_wall():
	while $RayCast2D.is_colliding():
		var collider = $RayCast2D.get_collider()
		if collider is Wall or collider is Door:
			return true
		else:
			$RayCast2D.add_exception(collider)
			$RayCast2D.force_raycast_update()
	return false
	

func move(delta: float):
	speed -= 5
	speed = max(speed, 0)
	var velocity =  movement_vector.normalized() * speed
	global_position += velocity * delta
	if speed == 0:
		should_move = false
		can_shoot = true


func rotate_wanderer(delta):
	rotation = lerp_angle(start_rotation, desired_rotation, elapsed)
	elapsed += delta
	if elapsed >= 1:
		should_rotate = false


#################################
## Shooting
#################################

func _on_timer_timeout() -> void:
	should_shoot = true


func attempt_shot():
	if can_shoot:
		shoot()
		should_shoot = false
		$ShootTimer.start()


func shoot():
	var new_bullet := bullet_scene.instantiate()
	new_bullet.direction = rotation
	new_bullet.global_position = global_position
	add_child(new_bullet)

#################################
## Collisions and Hits
#################################

func _on_area_entered(area: Area2D) -> void:
	if area is TrainCar:
		colliding_cars.append(area)
		$ShootTimer.set_paused(true)
		hit()
	if area is TrainBullet:
		hit()


func _on_area_exited(area: Area2D) -> void:
	if area is TrainCar:
		colliding_cars.remove_at(colliding_cars.find(area))


func _on_body_entered(body: Node2D) -> void:
	if body is Locomotive:
		colliding_cars.append(body)
		$ShootTimer.set_paused(true)
		hit()


func _on_body_exited(body: Node2D) -> void:
	if body is Locomotive:
		colliding_cars.remove_at(colliding_cars.find(body))


func hit():
	health -= 1
	if health <= 0:
		die()


func die():
	$ShootTimer.stop()
	died.emit()
	queue_free()
