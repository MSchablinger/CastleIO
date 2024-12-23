extends NavigationRegion2D

var tree: PackedScene = preload("res://World Objects/tree.tscn")
var rock: PackedScene = preload("res://World Objects/rock.tscn")
var keep: PackedScene = preload("res://Houses/castle_keep.tscn")

func _ready():
	init_resources()
	bake_navigation_polygon()

func init_resources() -> void:
	for pos: Vector2i in Utils.get_random_positions(10):
		var tree_instance: StaticBody2D = tree.instantiate()
		tree_instance.set_position(Game.tile_size * pos)
		add_child(tree_instance)
	for pos: Vector2i in Utils.get_random_positions(10):
		var rock_instance: StaticBody2D = rock.instantiate()
		rock_instance.set_position(Game.tile_size * pos)
		add_child(rock_instance)
