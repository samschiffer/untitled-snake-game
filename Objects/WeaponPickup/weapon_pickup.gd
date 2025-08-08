extends Area2D
class_name WeaponPickup


func _on_body_entered(body: Node2D) -> void:
	if body is Locomotive:
		hide()
		queue_free()
		body.collect_weapon_pickup.emit()
