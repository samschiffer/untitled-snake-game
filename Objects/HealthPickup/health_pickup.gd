extends Area2D
class_name HealthPickup


func _on_body_entered(body: Node2D) -> void:
	if body is Locomotive:
		hide()
		queue_free()
		body.collect_health_pickup.emit()
