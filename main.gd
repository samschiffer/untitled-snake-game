extends Node

# Scenes to load
var pickup_scene: PackedScene = preload("res://Objects/Pickup/pickup.tscn")
var health_pickup_scene: PackedScene = preload("res://Objects/HealthPickup/health_pickup.tscn")
var weapon_pickup_scene: PackedScene = preload("res://Objects/WeaponPickup/weapon_pickup.tscn")
var watcher_scene: PackedScene = preload("res://Characters/Watcher/watcher.tscn")
var wanderer_scene: PackedScene = preload("res://Characters/Wanderer/wanderer.tscn")
var train_scene: PackedScene = preload("res://Characters/Train/train.tscn")

var room_scene: PackedScene = preload("res://Environment/Room/room.tscn")
var special_room_scene: PackedScene = preload("res://Environment/SpecialRoom/SpecialRoom.tscn")
var player_train: Train

# Current Room variables
var current_room: Room
var room_width: float
var room_height: float

# List of rooms
var available_rooms = []
var rooms_index = 0

# Scoring variables
var score: int = 0
var level: int = 1

# Objectives
var objectives: Array[String] = ["enemies", "time", "score"]
var current_objective: String
var objective_progress: float = 0
var objective_goal: float
var objective_completed: bool = false

# Objective goals
var enemy_goal: int = 2
var score_goal: int = 300
var survive_goal: float = 30

# Camera controls
var camera_buffer = 200
var camera_follow_player: bool = false

# Spawn Rate vars
var pickup_spawn_rate: float = 5.0
var watcher_spawn_rate: float = 10.0
var health_spawn_rate: float = 20.0
var weapon_spawn_rate: float = 5.0
var watcher_health: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PickupSpawnTimer.wait_time = pickup_spawn_rate
	$WatcherSpawnTimer.wait_time = watcher_spawn_rate
	$HealthPickupSpawnTimer.wait_time = health_spawn_rate
	$WeaponPickupTimer.wait_time = weapon_spawn_rate
	
	available_rooms = [room_scene, special_room_scene]


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


func _physics_process(delta: float) -> void:
	if player_train:
		$HUD.update_current_boost(player_train.get_node("Locomotive").boost_amount)

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
	
	# Reset spawn rates
	pickup_spawn_rate = 5.0
	watcher_spawn_rate = 10.0
	health_spawn_rate = 20.0
	
	$PickupSpawnTimer.wait_time = pickup_spawn_rate
	$WatcherSpawnTimer.wait_time = watcher_spawn_rate
	$HealthPickupSpawnTimer.wait_time = health_spawn_rate
	$WeaponPickupTimer.wait_time = weapon_spawn_rate
	
	# Reset objective goals
	enemy_goal = 2
	score_goal = 300
	survive_goal = 30

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
	$HUD.update_max_boost(player_train.get_node("Locomotive").boost_amount)
	$HUD.update_score(0)
	$HUD.update_level(level)
	
	# Show the player
	player_train.show()
	
	# Spawn some pickups and enemies to start
	spawn_pickup()
	spawn_pickup()
	spawn_pickup()
	spawn_watcher()
	spawn_watcher()
	spawn_wanderer()
	
	# Start the timers for spawning new pickups and enemies
	$PickupSpawnTimer.start()
	$HealthPickupSpawnTimer.start()
	$WeaponPickupTimer.start()
	$WatcherSpawnTimer.start()
	$WandererSpawnTimer.start()


func get_new_objective():
	# Don't repeat the same objective twice
	var objectives_choices: Array[String] = objectives.duplicate()
	objectives_choices.erase(current_objective)
	
	current_objective = objectives_choices.pick_random()
	
	match current_objective:
		"time":
			start_survive_timer(survive_goal)
			survive_goal += 5
		"enemies":
			objective_progress = 0
			objective_goal = enemy_goal
			enemy_goal += 1
		"score":
			objective_progress = 0
			objective_goal = score_goal
			score_goal += 100
			
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
	$WeaponPickupTimer.stop()
	$WatcherSpawnTimer.stop()
	$WandererSpawnTimer.stop()
	
	# Open the doors so they can move to the next level
	open_doors()


func open_doors():
	if player_train != null:
		current_room.open_all_doors_for(player_train.get_node("Locomotive"))


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


func get_random_spawn_point():
	var room_width = current_room.bounding_box.x
	var room_height = current_room.bounding_box.y
	var rand_y: float
	var rand_x: float
	
	var room_floor: Polygon2D = current_room.floor
	var room_floor_polygon: PackedVector2Array = room_floor.polygon
	var transformed_polygon_points = []
	for point_local in room_floor_polygon:
		var point_global = room_floor.to_global(point_local)
		transformed_polygon_points.append(point_global)
		
	var spawn_point_in_room = false
	var tries = 0
	while not spawn_point_in_room:
		rand_x = randf_range(60.0, room_width - 60.0)
		rand_y = randf_range(60.0, room_height - 60.0)
		spawn_point_in_room = Geometry2D.is_point_in_polygon(Vector2(rand_x, rand_y), transformed_polygon_points)
		tries += 1
		if tries > 500:
			print("Timed out: could not find point in room") # TODO Add better error handling
			spawn_point_in_room = true
	
	return Vector2(rand_x, rand_y)

func _on_pickup_timer_timeout() -> void:
	spawn_pickup()


# Spawns a pickup at a random location on the screen
func spawn_pickup():
	var new_pickup: Area2D = pickup_scene.instantiate()
	new_pickup.position = get_random_spawn_point()
	add_child(new_pickup)


func _on_collect_pickup():
	increment_score(20)


func _on_watcher_spawn_timer_timeout() -> void:
	spawn_watcher()


# Spawns a watcher at a random location on the screen
func spawn_watcher():
	var new_watcher: Area2D = watcher_scene.instantiate()
	new_watcher.health = watcher_health
	new_watcher.position = get_random_spawn_point()
	new_watcher.died.connect(_on_enemy_death)
	add_child(new_watcher)


func _on_enemy_death():
	increment_score(100)
	if current_objective == "enemies" and not objective_completed:
		objective_progress += 1
		$HUD.update_objective_progress(objective_progress)


func _on_wanderer_spawn_timer_timeout() -> void:
	spawn_wanderer()


# Spawns an enemy at a random location on the screen
func spawn_wanderer():
	var new_wanderer: Area2D = wanderer_scene.instantiate()
	new_wanderer.health = 7
	new_wanderer.position = get_random_spawn_point()
	new_wanderer.died.connect(_on_enemy_death)
	add_child(new_wanderer)


func _on_health_pickup_spawn_timer_timeout() -> void:
	spawn_health_pickup()


func spawn_health_pickup():
	var new_pickup: Area2D = health_pickup_scene.instantiate()
	new_pickup.position = get_random_spawn_point()
	add_child(new_pickup)


func _on_weapon_pickup_timer_timeout() -> void:
	spawn_weapon_pickup()


func spawn_weapon_pickup():
	var new_pickup: Area2D = weapon_pickup_scene.instantiate()
	new_pickup.position = get_random_spawn_point()
	add_child(new_pickup)


func _on_train_died() -> void:
	game_over()


func game_over():
	$PickupSpawnTimer.stop()
	$HealthPickupSpawnTimer.stop()
	$WeaponPickupTimer.stop()
	$WatcherSpawnTimer.stop()
	$WandererSpawnTimer.stop()
	$HUD.show_game_over()
	
	await get_tree().create_timer(3.0).timeout
	
	clear_room()
	current_room.queue_free()


func clear_room():
	get_tree().call_group("Enemies", "queue_free")
	get_tree().call_group("Wanderers", "queue_free")
	get_tree().call_group("Pickups", "queue_free")
	get_tree().call_group("HealthPickups", "queue_free")
	get_tree().call_group("WeaponPickups", "queue_free")


## Room Movement Code
func _on_room_train_left_room(from_direction: String) -> void:
	$Transition.fade()
	player_train.get_node("Locomotive").speed = 0
	go_to_next_room(from_direction)


func _on_room_train_entered_room(train: Train) -> void:
	# Unlock the player movement
	player_train.get_node("Locomotive").movement_locked = false
	
	# Start the enemy and pickup spawners
	$PickupSpawnTimer.start()
	$HealthPickupSpawnTimer.start()
	$WeaponPickupTimer.start()
	$WatcherSpawnTimer.start()
	$WandererSpawnTimer.start()
	
	# Close the doors
	await get_tree().create_timer(1.0).timeout
	current_room.close_all_doors_for(player_train.get_node("Locomotive"))
	
	# Initial spawns in room
	await get_tree().create_timer(1.0).timeout
	spawn_pickup()
	spawn_pickup()
	spawn_pickup()
	spawn_watcher()
	spawn_watcher()
	spawn_wanderer()


func go_to_next_room(from_direction: String):
	await get_tree().create_timer(2.0).timeout ## TODO: Add signals to animation completing to control this behavior
	clear_room()
	increase_level()
	get_new_objective()
	change_rooms()
	
	var train_entry
	match from_direction:
		"top":
			train_entry = current_room.entry_bottom
		"left":
			train_entry = current_room.entry_right
		"bottom":
			train_entry = current_room.entry_top
		"right":
			train_entry = current_room.entry_left
	
	# Go to the entry point
	$Train/Locomotive.rotation = train_entry.rotation
	$Train.move_to(train_entry.position)
	$Camera2D.position = train_entry.position
	$Camera2D.reset_smoothing()

	current_room.check_for_train_entered(player_train)
	player_train.get_node("Locomotive").show()
	player_train.get_node("Locomotive").speed = 600
	$Transition.unfade()

func change_rooms():
	# Tear down current room
	current_room.queue_free()
	
	# Choose which room
	rooms_index = (rooms_index + 1) % 2
	var room_scene = available_rooms[rooms_index]
	
	# Create new room
	var new_room = room_scene.instantiate()
	$Camera2D.add_sibling(new_room)
	current_room = new_room
	
	# Change the camera limits
	$Camera2D.limit_left = current_room.position.x - camera_buffer
	$Camera2D.limit_top = current_room.position.y - camera_buffer
	$Camera2D.limit_right =  current_room.position.x + current_room.bounding_box.x + camera_buffer
	$Camera2D.limit_bottom = current_room.position.y + current_room.bounding_box.y + camera_buffer
	
	# Connect room to signals
	current_room.train_left_room.connect(_on_room_train_left_room)
	current_room.train_entered_room.connect(_on_room_train_entered_room)
	
	# Open doors for the player
	current_room.open_all_doors_for(player_train.get_node("Locomotive"))


func increase_level():
	level += 1
	$HUD.update_level(level)
	
	pickup_spawn_rate += 0.5
	watcher_spawn_rate -= 0.25
	health_spawn_rate += 0.5
	
	$PickupSpawnTimer.wait_time = pickup_spawn_rate
	$WatcherSpawnTimer.wait_time = watcher_spawn_rate
	$HealthPickupSpawnTimer.wait_time = health_spawn_rate
	
	if level % 3 == 0:
		watcher_health += 2
