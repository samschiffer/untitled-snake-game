extends Node

# Scenes to load
var pickup_scene: PackedScene = preload("res://Objects/Pickup/pickup.tscn")
var health_pickup_scene: PackedScene = preload("res://Objects/HealthPickup/health_pickup.tscn")
var enemy_scene: PackedScene = preload("res://Characters/Enemy/enemy.tscn")
var train_scene: PackedScene = preload("res://Characters/Train/train.tscn")
var room_scene: PackedScene = preload("res://Environment/Room/room.tscn")
var player_train: Train

# Current Room variables
var current_room
var room_width: float
var room_height: float

# Scoring variables
var score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## Debugging Mouse Position
	#if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#print("Mouse position", get_viewport().get_mouse_position())
	pass


func _on_hud_start_game() -> void:
	create_room()

func create_room():
	# Create room
	current_room = room_scene.instantiate()
	current_room.ready.connect(start_game)
	add_child(current_room)
	

func start_game():
	# Reset score
	score = 0
	
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
	score += 20
	$HUD.update_score(score)
	

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
	score += 100
	$HUD.update_score(score)


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
	
	get_tree().call_group("Enemies", "queue_free")
	get_tree().call_group("Pickups", "queue_free")
	get_tree().call_group("HealthPickups", "queue_free")
	current_room.queue_free()
