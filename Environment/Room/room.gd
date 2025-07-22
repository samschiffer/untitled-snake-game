extends Node2D

@onready var bounding_box

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_bounding_box()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_bounding_box():
	var min_x = INF
	var max_x = -INF
	
	var min_y = INF
	var max_y = -INF
	
	var polygon_points = $Floor.polygon
	var scaled_points = polygon_points * $Floor.global_transform
	
	for point in scaled_points:
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)
		
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		
	bounding_box = Vector2(max_x - min_x, max_y - min_y)	
