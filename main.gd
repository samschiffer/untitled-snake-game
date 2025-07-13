extends Node

var pickup_scene = preload("res://pickup.tscn")
var enemy_scene = load("res://enemy.tscn")
var train_scene = preload("res://train.tscn")
var player_train

var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Train.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_pickup():
	var viewport_size = get_viewport().get_visible_rect().size
	var rand_x = randf_range(20.0, viewport_size.x - 20.0)
	var rand_y = randf_range(20.0, viewport_size.y - 20.0)
	var new_pickup = pickup_scene.instantiate()
	new_pickup.position = Vector2(rand_x, rand_y)
	add_child(new_pickup)


func spawn_enemy():
	var viewport_size = get_viewport().get_visible_rect().size
	var rand_x = randf_range(40.0, viewport_size.x - 40.0)
	var rand_y = randf_range(40.0, viewport_size.y - 40.0)
	var new_enemy = enemy_scene.instantiate()
	new_enemy.position = Vector2(rand_x, rand_y)
	new_enemy.died.connect(_on_enemy_death)
	add_child(new_enemy)


func start_game():
	score = 0
	if has_node("Train"):
		player_train = $Train
	else:
		player_train = train_scene.instantiate()
		add_child(player_train)
		player_train.hide()
	$HUD.update_max_health(player_train.health)
	$HUD.update_current_health(player_train.health)
	$HUD.update_score(0)
	player_train.died.connect(_on_train_died)
	player_train.health_changed.connect(_on_health_changed)
	player_train.move_to(Vector2(960, 540))
	player_train.show()
	player_train.get_node("Locomotive").collect_pickup.connect(_on_collect_pickup)
	#$Train.move_to(Vector2(300, 300))
	#$Train.show()
	spawn_pickup()
	spawn_pickup()
	spawn_pickup()
	spawn_enemy()
	spawn_enemy()
	$PickupTimer.start()
	$EnemySpawnTimer.start()
	

func game_over():
	$PickupTimer.stop()
	$EnemySpawnTimer.stop()
	$HUD.show_game_over()
	await get_tree().create_timer(3.0).timeout
	get_tree().call_group("Enemies", "queue_free")
	get_tree().call_group("Pickups", "queue_free")


func _on_pickup_timer_timeout() -> void:
	spawn_pickup()
	pass # Replace with function body.

func _on_collect_pickup():
	score += 20
	$HUD.update_score(score)
	

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
	pass # Replace with function body.

func _on_enemy_death():
	score += 100
	$HUD.update_score(score)

func _on_health_changed():
	$HUD.update_current_health(player_train.health)
	

func _on_train_died() -> void:
	game_over()
	pass # Replace with function body.


func _on_hud_start_game() -> void:
	start_game()
	pass # Replace with function body.
