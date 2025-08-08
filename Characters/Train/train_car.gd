extends Area2D
class_name TrainCar

signal train_car_death(node: Node)

var bullet_scene: PackedScene = preload("res://Objects/TrainBullet/train_bullet.tscn")

var max_health: float = 2
var health: float

var type: String = "normal"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if type == "gun":
		if Input.is_action_just_pressed("shoot_left"):
			shoot("left")
		elif Input.is_action_just_pressed("shoot_right"):
			shoot("right")
	
	$HealthLabel.text = str(health)
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is Shuriken:
		health -= 1
		if health <= 0:
			train_car_death.emit(self)


func shoot(direction: String):
	var bullet_speed: float = 600
	var bullet_offset: float = 30
	
	var root_node = get_tree().root
	var new_bullet: TrainBullet = bullet_scene.instantiate()
	
	var rotation_add
	if direction == "left":
		rotation_add = 3 * PI / 2
	else:
		rotation_add = PI / 2
	
	var velocity = (Vector2.UP.rotated(rotation + rotation_add) * bullet_speed) 
	new_bullet.velocity = velocity
	
	new_bullet.global_position = global_position + Vector2.UP.rotated(rotation + rotation_add) * bullet_offset
	root_node.add_child(new_bullet)
