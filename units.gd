extends Node2D

var peasant = preload("res://unit/peasant.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pos: Vector2i in Utils.get_random_positions(10):
		var peasant_instance = peasant.instantiate()
		peasant_instance.set_position(Game.tile_size * pos)
		add_child(peasant_instance)
