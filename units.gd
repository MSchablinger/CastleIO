extends Node2D

var peasant = preload("res://Entities/peasant.tscn")

signal wave_cleared

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemies()

func _process(delta: float) -> void:
	if get_child_count() == 0:
		wave_cleared.emit()
		Game.wave+=1
		spawn_enemies()

func spawn_enemies():
	for pos: Vector2i in Utils.get_random_positions(Game.wave * 5):
		var peasant_instance = peasant.instantiate()
		peasant_instance.set_position(Game.tile_size * pos)
		add_child(peasant_instance)
