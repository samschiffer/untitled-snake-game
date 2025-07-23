extends CanvasLayer

signal start_game

# Health variables
var max_health: float = 100
@onready var initial_health_bar_width = $HealthLabel/ColorRect.size.x

# Objective variables
var current_objective: String
var objective_goal: String
var objective_progress: String
var objective_name_map := {
	"enemies": "Defeat Enemies:",
	"time": "Survive for",
	"score": "Score Points:"
}

func _ready() -> void:
	$HealthLabel.hide()
	$ScoreLabel.hide()
	$ObjectiveLabel.hide()
	$LevelLabel.hide()


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_pushed()


func start_pushed():
	$Message.text = "Get Ready"
	$Message.show()
	await get_tree().create_timer(2.0).timeout
	$Message.text = "GO!"
	await get_tree().create_timer(1.0).timeout
	$Message.hide()
	$HealthLabel.show()
	$ScoreLabel.show()
	$ObjectiveLabel.show()
	$LevelLabel.show()
	start_game.emit()


func show_game_over():
	$Message.text = "Game Over"
	$Message.show()
	await get_tree().create_timer(5.0).timeout
	$Message.text = "Play Again?"
	$HealthLabel.hide()
	$ScoreLabel.hide()
	$ObjectiveLabel.hide()
	$LevelLabel.hide()
	$StartButton.show()


func update_max_health(health: float):
	max_health = health


func update_current_health(current_health: float):
	$HealthLabel/ColorRect.size.x = initial_health_bar_width * (current_health / max_health)


func update_score(score: int):
	$ScoreLabel.text = "Score: " + str(score)

func update_objective(objective: String):
	current_objective = objective

func update_objective_progress(progress, goal = null):
	objective_progress = str(progress)
	if goal != null:
		objective_goal = str(goal)
	
	if current_objective == "time":
		$ObjectiveLabel.text = objective_name_map[current_objective] + " " + objective_progress + "s"
	else:
		$ObjectiveLabel.text = objective_name_map[current_objective] + " " + objective_progress + "/" + objective_goal


func update_level(level):
	$LevelLabel.text = "Level: " + str(level)
