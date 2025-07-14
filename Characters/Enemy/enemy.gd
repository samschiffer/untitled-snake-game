extends Area2D

signal died

@export var shoot_cooldown := 1
@export var health := 10
@export var bullet_scene: PackedScene = preload("res://Objects/shuriken.tscn")

@onready var player_train := get_tree().get_first_node_in_group("Trains")

var colliding_cars: Array[Area2D] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Unpause the shoot timer if there are no cars attacking (colliding with) the enemy
	if colliding_cars.size() == 0:
		$ShootTimer.set_paused(false)
	
	# Update the health label
	$Label.text = str(health)
	$Label2.text = String.num(snapped($ShootTimer.time_left, 0.1))
	
	# Debugging the shoot function
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	# Rotate towards the train's locomotive if it exists
	if player_train:
		rotation = global_position.direction_to(player_train.get_node("Locomotive").global_position).angle() + PI / 2


func _on_timer_timeout() -> void:
	shoot()


func shoot():
	var new_bullet := bullet_scene.instantiate()
	new_bullet.direction = rotation
	new_bullet.global_position = global_position
	add_child(new_bullet)


func _on_area_entered(area: Area2D) -> void:
	if area is Locomotive or area is TrainCar:
		colliding_cars.append(area)
		$ShootTimer.set_paused(true)
		hit()


func _on_area_exited(area: Area2D) -> void:
	if area is Locomotive or area is TrainCar:
		colliding_cars.remove_at(colliding_cars.find(area))


func hit():
	health -= 1
	if health <= 0:
		die()


func die():
	$ShootTimer.stop()
	died.emit()
	queue_free()
