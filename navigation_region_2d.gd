extends NavigationRegion2D

var tree: PackedScene = preload("res://World Objects/tree.tscn")
var rock: PackedScene = preload("res://World Objects/rock.tscn")
var keep: PackedScene = preload("res://Houses/castle_keep.tscn")

func _ready():
	init_resources()
	bake_navigation_polygon()

func init_resources() -> void:
	for pos: Vector2i in get_random_positions(10):
		var tree_instance: StaticBody2D = tree.instantiate()
		tree_instance.set_position(Game.tile_size * pos)
		add_child(tree_instance)
	for pos: Vector2i in get_random_positions(10):
		var rock_instance: StaticBody2D = rock.instantiate()
		rock_instance.set_position(Game.tile_size * pos)
		add_child(rock_instance)

func get_random_positions(amount: int) -> Array:
	var positions: Array = []
	for i: int in range(amount):
		var x_coor: int = randi() % int(Game.grid_size.x)
		var y_coor: int = randi() % int(Game.grid_size.y)
		var grid_position: Vector2i = Vector2i(x_coor, y_coor)
		if not grid_position in positions:
			positions.append(grid_position)
	return positions
