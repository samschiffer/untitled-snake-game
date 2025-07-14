extends Area2D
class_name TrainCar

signal train_car_death(node: Node)

var max_health: float = 2
var health: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$HealthLabel.text = str(health)
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is Shuriken:
		health -= 1
		if health <= 0:
			train_car_death.emit(self)
