extends Area2D
class_name TrainCar

@export var times_too_close: int = 0
@export var current_velocity: Vector2

signal train_car_hit(node: Node)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is Shuriken:
		train_car_hit.emit(self)
