extends Area2D
class_name Shuriken

var direction = 0
var speed := 200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity: Vector2 = Vector2.UP.rotated(direction) * speed
	position += velocity * delta


func _on_area_entered(area: Area2D) -> void:
	if area is TrainCar:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Locomotive:
		body.locomotive_hit.emit()
		queue_free()
