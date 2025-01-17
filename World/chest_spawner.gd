extends Node2D

var chest_scene = preload("res://World/chest.tscn")

var min_spawn_time := 5.0
var max_spawn_time := 30.0
var min_chests := 1
var max_chests := 3

@onready var spawn_area: CollisionShape2D = $SpawnArea/CollisionShape2D

func _ready() -> void:
	# Connect to the wave_cleared signal from the Units node
	var units_node = get_node("/root/World/Units")
	if units_node:
		units_node.wave_cleared.connect(_on_wave_cleared)
	
	# Connect to game over signal
	var game_over = get_node("/root/World/GameOver")
	if game_over:
		game_over.retry_pressed.connect(_on_game_over)
	
	# Initial spawn
	spawn_chest_wave()

func _on_wave_cleared() -> void:
	spawn_chest_wave()

func _on_game_over() -> void:
	# Clear existing chests immediately
	get_tree().call_group("chests", "queue_free")
	
	# Cancel any pending spawns
	for child in get_children():
		if child is Timer:
			child.stop()
			child.queue_free()

func spawn_chest_wave() -> void:
	# Determine number of chests for this wave
	var num_chests = randi_range(min_chests, max_chests)
	
	# Generate spawn times
	var spawn_times = []
	for i in num_chests:
		spawn_times.append(randf_range(min_spawn_time, max_spawn_time))
	
	# Sort spawn times for better scheduling
	spawn_times.sort()
	
	# Schedule chest spawns
	for spawn_time in spawn_times:
		var timer = get_tree().create_timer(spawn_time)
		timer.timeout.connect(spawn_single_chest)

func get_random_position() -> Vector2:
	var rect_shape = spawn_area.shape as RectangleShape2D
	var size = rect_shape.size
	var area_position = spawn_area.global_position
	
	# Get random position within rectangle, relative to the spawn area's position
	var x = randf_range(-size.x/2, size.x/2) + area_position.x
	var y = randf_range(-size.y/2, size.y/2) + area_position.y
	
	return Vector2(x, y)

func spawn_single_chest() -> void:
	var chest_instance = chest_scene.instantiate()
	chest_instance.position = get_random_position()
	
	# Randomly decide if it's a gold chest (30% chance)
	var is_gold = randf() < 0.3
	chest_instance.init(chest_instance.ChestType.GOLD if is_gold else chest_instance.ChestType.NORMAL)
	
	add_child(chest_instance)
	print("Spawned chest at: ", chest_instance.position)
