extends Node

# Scenes to load
var pickup_scene: PackedScene = preload("res://Objects/Pickup/pickup.tscn")
var health_pickup_scene: PackedScene = preload("res://Objects/HealthPickup/health_pickup.tscn")
var enemy_scene: PackedScene = preload("res://Characters/Enemy/enemy.tscn")
var train_scene: PackedScene = preload("res://Characters/Train/train.tscn")
var room_scene: PackedScene = preload("res://Environment/Room/room.tscn")
var player_train: Train

# Current Room variables
var current_room: Room
var room_width: float
var room_height: float

# Scoring variables
var score: int = 0
var level: int = 1

# Objectives
var objectives: Array[String] = ["enemies", "time", "score"]
var current_objective: String
var objective_progress: float = 0
var objective_goal: float
var objective_completed: bool = false

# Camera controls
var camera_buffer = 200
var camera_follow_player: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make the camera follow the player
	if camera_follow_player == true and player_train != null:
		$Camera2D.position = player_train.get_node("Locomotive").position
	## Debugging Mouse Position
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("Mouse position", get_viewport().get_mouse_position())
	if Input.is_action_just_pressed("test_action"):
		pass
	if current_objective == "time":
		objective_progress = snapped($SurviveTimer.time_left, 0.1)
		if not objective_completed:
			$HUD.update_objective_progress(objective_progress)
	if not objective_completed and is_objective_complete():
		complete_objective()


func _on_hud_start_game() -> void:
	create_room()

func create_room():
	# Create room
	current_room = room_scene.instantiate()
	current_room.ready.connect(start_game)
	current_room.train_entered_room.connect(_on_room_train_entered_room)
	current_room.train_left_room.connect(_on_room_train_left_room)
	add_child(current_room)
	

func start_game():
	# Set camera limits
	$Camera2D.limit_left = current_room.position.x - camera_buffer
	$Camera2D.limit_top = current_room.position.y - camera_buffer
	$Camera2D.limit_right =  current_room.position.x + current_room.bounding_box.x + camera_buffer
	$Camera2D.limit_bottom =  current_room.position.y + current_room.bounding_box.y + camera_buffer
	camera_follow_player = true
	
	# Reset score
	score = 0
	
	# Reset level
	level = 1
	
	# Set objective
	get_new_objective()
	
	room_width = current_room.bounding_box.x
	room_height = current_room.bounding_box.y
	
	# Create a new train
	player_train = train_scene.instantiate()
	add_child(player_train)
	player_train.hide()
	player_train.move_to(Vector2(room_width / 2, room_height / 2))
	
	# Connect to train signals
	player_train.died.connect(_on_train_died)
	player_train.health_changed.connect(_on_health_changed)
	player_train.get_node("Locomotive").collect_pickup.connect(_on_collect_pickup)
	
	# Update the HUD values 
	$HUD.update_max_health(player_train.health)
	$HUD.update_current_health(player_train.health)
	$HUD.update_score(0)
	$HUD.update_level(level)
	
	# Show the player
	player_train.show()
	
	# Spawn some pickups and enemies to start
	spawn_pickup()
	spawn_pickup()
	spawn_pickup()
	spawn_enemy()
	spawn_enemy()
	
	# Start the timers for spawning new pickups and enemies
	$PickupSpawnTimer.start()
	$HealthPickupSpawnTimer.start()
	$EnemySpawnTimer.start()


func get_new_objective():
	# Don't repeat the same objective twice
	var objectives_choices: Array[String] = objectives.duplicate()
	objectives_choices.erase(current_objective)
	
	current_objective = objectives_choices.pick_random()
	
	match current_objective:
		"time":
			start_survive_timer(10)
		"enemies":
			objective_progress = 0
			objective_goal = 3
		"score":
			objective_progress = 0
			objective_goal = 200
			
	objective_completed = false
	
	$HUD.update_objective(current_objective)
	$HUD.update_objective_progress(objective_progress, objective_goal)


func is_objective_complete():
	if current_objective in ["enemies", "score"]:
		return objective_progress >= objective_goal
	elif current_objective in ["time"]:
		return objective_progress <= objective_goal
	else:
		return false


func complete_objective():
	# Complete objective
	objective_completed = true
	$HUD.update_objective_complete()
	
	# Give player points for completing
	increment_score(500)
	
	# Stop spawning enemies and pickups
	$PickupSpawnTimer.stop()
	$HealthPickupSpawnTimer.stop()
	$EnemySpawnTimer.stop()
	
	# Open the doors so they can move to the next level
	open_doors()


func open_doors():
	if player_train != null:
		current_room.get_node("DoorTop").open_for(player_train.get_node("Locomotive"))
		current_room.get_node("DoorLeft").open_for(player_train.get_node("Locomotive"))
		current_room.get_node("DoorRight").open_for(player_train.get_node("Locomotive"))
		current_room.get_node("DoorBottom").open_for(player_train.get_node("Locomotive"))


func increment_score(amount: int):
	score += amount
	$HUD.update_score(score)
	if current_objective == "score" and not objective_completed:
		objective_progress += amount
		$HUD.update_objective_progress(objective_progress)


func start_survive_timer(survive_time):
	objective_progress = survive_time
	objective_goal = 0
	$SurviveTimer.wait_time = survive_time
	$SurviveTimer.start()


func _on_health_changed():
	$HUD.update_current_health(player_train.health)


func _on_pickup_timer_timeout() -> void:
	spawn_pickup()


# Spawns a pickup at a random location on the screen
func spawn_pickup():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var rand_x: float = randf_range(60.0, room_width - 60.0)
	var rand_y: float = randf_range(60.0, room_height - 60.0)
	var new_pickup: Area2D = pickup_scene.instantiate()
	new_pickup.position = Vector2(rand_x, rand_y)
	add_child(new_pickup)


func _on_collect_pickup():
	increment_score(20)


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()


# Spawns an enemy at a random location on the screen
func spawn_enemy():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var rand_x: float = randf_range(80.0, room_width - 80.0)
	var rand_y: float = randf_range(80.0, room_height - 80.0)
	var new_enemy: Area2D = enemy_scene.instantiate()
	new_enemy.position = Vector2(rand_x, rand_y)
	new_enemy.died.connect(_on_enemy_death)
	add_child(new_enemy)


func _on_enemy_death():
	increment_score(100)
	if current_objective == "enemies" and not objective_completed:
		objective_progress += 1
		$HUD.update_objective_progress(objective_progress)


func _on_health_pickup_spawn_timer_timeout() -> void:
	spawn_health_pickup()


func spawn_health_pickup():
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var rand_x: float = randf_range(60.0, room_width - 60.0)
	var rand_y: float = randf_range(60.0, room_height - 60.0)
	var new_pickup: Area2D = health_pickup_scene.instantiate()
	new_pickup.position = Vector2(rand_x, rand_y)
	add_child(new_pickup)


func _on_train_died() -> void:
	game_over()


func game_over():
	$PickupSpawnTimer.stop()
	$HealthPickupSpawnTimer.stop()
	$EnemySpawnTimer.stop()
	$HUD.show_game_over()
	
	await get_tree().create_timer(3.0).timeout
	
	clear_room()
	current_room.queue_free()


func clear_room():
	get_tree().call_group("Enemies", "queue_free")
	get_tree().call_group("Pickups", "queue_free")
	get_tree().call_group("HealthPickups", "queue_free")


## Room Movement Code
func _on_room_train_left_room(from_direction: String) -> void:
	$Transition.fade()
	player_train.get_node("Locomotive").speed = 0
	go_to_next_room(from_direction)


func _on_room_train_entered_room(train: Train) -> void:
	# Close the doors
	current_room.get_node("DoorTop").close_for(player_train.get_node("Locomotive"))
	current_room.get_node("DoorLeft").close_for(player_train.get_node("Locomotive"))
	current_room.get_node("DoorBottom").close_for(player_train.get_node("Locomotive"))
	current_room.get_node("DoorRight").close_for(player_train.get_node("Locomotive"))
	
	# Unlock the player movement
	player_train.get_node("Locomotive").movement_locked = false
	
	# Start the enemy and pickup spawners
	$PickupSpawnTimer.start()
	$HealthPickupSpawnTimer.start()
	$EnemySpawnTimer.start()


func go_to_next_room(from_direction: String):
	await get_tree().create_timer(2.0).timeout ## TODO: Add signals to animation completing to control this behavior
	clear_room()
	level += 1
	$HUD.update_level(level)
	get_new_objective()
	
	# Move the player outside of the correct door based on which door they exited the last room from
	match from_direction:
		"top":
			# Go to the bottom
			player_train.get_node("Locomotive").rotation = 0
			player_train.move_to(Vector2(current_room.get_node("ExitBottom").position.x, current_room.get_node("ExitBottom").position.y + 40))
			$Camera2D.position = current_room.get_node("ExitBottom").position
			$Camera2D.reset_smoothing()
		"left":
			# Go to the right
			player_train.get_node("Locomotive").rotation = (3 * PI) / 2.0
			player_train.move_to(Vector2(current_room.get_node("ExitRight").position.x + 40, current_room.get_node("ExitRight").position.y))
			$Camera2D.position = current_room.get_node("ExitRight").position
			$Camera2D.reset_smoothing()
		"bottom":
			# Go to the top
			player_train.get_node("Locomotive").rotation = PI
			player_train.move_to(Vector2(current_room.get_node("ExitTop").position.x, current_room.get_node("ExitTop").position.y - 40))
			$Camera2D.position = current_room.get_node("ExitTop").position
			$Camera2D.reset_smoothing()
		"right":
			# Go to the left
			player_train.get_node("Locomotive").rotation = PI / 2
			player_train.move_to(Vector2(current_room.get_node("ExitLeft").position.x - 40, current_room.get_node("ExitLeft").position.y))
			$Camera2D.position = current_room.get_node("ExitLeft").position
			$Camera2D.reset_smoothing()
	
	current_room.check_for_train_entered(player_train)
	player_train.get_node("Locomotive").show()
	player_train.get_node("Locomotive").speed = 600
	$Transition.unfade()
