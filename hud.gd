extends CanvasLayer

signal start_game

var max_health: float = 100
var current_health: float = 100
@onready var initial_health_bar_width = $HealthLabel/ColorRect.size.x

func _ready() -> void:
	$HealthLabel.hide()
	$ScoreLabel.hide()

func _on_button_pressed() -> void:
	$Button.hide()
	start_pushed()
	pass # Replace with function body.

func start_pushed():
	$Message.text = "Get Ready"
	$Message.show()
	await get_tree().create_timer(2.0).timeout
	$Message.text = "GO!"
	await get_tree().create_timer(1.0).timeout
	$Message.hide()
	$HealthLabel.show()
	$ScoreLabel.show()
	start_game.emit()

func show_game_over():
	$Message.text = "Game Over"
	$Message.show()
	await get_tree().create_timer(5.0).timeout
	$Message.text = "Play Again?"
	$HealthLabel.hide()
	$ScoreLabel.hide()
	$Button.show()


func _on_timer_timeout() -> void:
	#$ColorRect.size.x -= 10
	#print(Player_Train.health)
	pass # Replace with function body.


func update_max_health(health: float):
	max_health = health
	

func update_current_health(current_health: float):
	$HealthLabel/ColorRect.size.x = initial_health_bar_width * (current_health / max_health)
	
func update_score(score: int):
	$ScoreLabel/Score.text = str(score)
