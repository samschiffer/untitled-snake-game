extends Area2D
class_name TrainBullet

var velocity: Vector2
@export var despawn_time: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(despawn_time).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area is TrainCar or area is Enemy or area is Wanderer:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Locomotive:
		queue_free()
