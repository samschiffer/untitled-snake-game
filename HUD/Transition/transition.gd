extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.size = get_viewport().get_visible_rect().size
	$ColorRect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fade():
	$ColorRect.visible = true
	$AnimationPlayer.play("fade_to_black")


func unfade():
	$AnimationPlayer.play("fade_to_normal")
	#$ColorRect.visible = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		pass
	elif anim_name == "fade_to_normal":
		$ColorRect.visible = false
