extends Node2D

var peasant = preload("res://Entities/peasant.tscn")

signal wave_cleared

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to game over signal
	var game_over = get_node("/root/World/GameOver")
	if game_over:
		game_over.retry_pressed.connect(_on_game_over)
	
	spawn_enemies()

func _process(_delta: float) -> void:
	if get_child_count() == 0:
		wave_cleared.emit()
		Game.wave += 1
		spawn_enemies()

func _on_game_over() -> void:
	Game.wave = 1

func spawn_enemies():
	for pos: Vector2i in Utils.get_random_positions(Game.wave * 5):
		var peasant_instance = peasant.instantiate()
		peasant_instance.set_position(Game.tile_size * pos)
		add_child(peasant_instance)
