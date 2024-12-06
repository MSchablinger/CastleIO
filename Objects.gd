extends Node2D

enum { OBSTACLE, COLLECTABLE, RESOURCE }

var tile_size: int = 16
var grid_size: Vector2i = Vector2i(64, 48)
var grid: Array = []

var tree: PackedScene = preload("res://World Objects/tree.tscn")
var rock: PackedScene = preload("res://World Objects/rock.tscn")
var house: PackedScene = preload("res://Houses/gold_mine.tscn")
var keep: PackedScene = preload("res://Houses/castle_keep.tscn")

func _ready():
	init_empty_grid()
	#init_resources()

func init_empty_grid() -> void:
	for x: int in range(grid_size.x):
		grid.append([])
		for y: int in range(grid_size.y):
			grid[x].append(null)

func init_resources() -> void:
	for pos: Vector2i in get_random_positions(10):
		var tree_instance: StaticBody2D = tree.instantiate()
		tree_instance.set_position(tile_size * pos)
		grid[pos.x][pos.y] = OBSTACLE
		add_child(tree_instance)
	for pos: Vector2i in get_random_positions(10):
		var rock_instance: StaticBody2D = rock.instantiate()
		rock_instance.set_position(tile_size * pos)
		grid[pos.x][pos.y] = OBSTACLE
		add_child(rock_instance)
	var mini_map_node: SubViewport = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
	mini_map_node.update_trees()
	mini_map_node.update_rocks()

func get_random_positions(amount: int) -> Array:
	var positions: Array = []
	for i: int in range(amount):
		var x_coor: int = randi() % int(grid_size.x)
		var y_coor: int = randi() % int(grid_size.y)
		var grid_position: Vector2i = Vector2i(x_coor, y_coor)
		if not grid_position in positions:
			positions.append(grid_position)
	return positions

func _input(event) -> void:
	if event.is_action_pressed("LeftClick"):
		var cost = 10
		if Game.gold_mine_count != 0:
			cost = cost * Game.gold_mine_count
		if Game.wood >= cost and Game.stone >= cost:
			var mouse_position: Vector2 = get_global_mouse_position()
			var multi_x: int = int(round(mouse_position.x) / tile_size)
			var multi_y: int = int(round(mouse_position.y) / tile_size)
			var new_pos: Vector2i = Vector2i(multi_x, multi_y)
			
			var around: bool = false
			for i: int in range(tile_size):
				if (multi_x + i < grid.size() and multi_x + i >= 0 and multi_y >= 0 and multi_y < grid[multi_x + i].size() and grid[multi_x + i][multi_y] != null) or(multi_x - i >= 0 and multi_x - i < grid.size() and multi_y >= 0 and multi_y < grid[multi_x - i].size() and grid[multi_x - i][multi_y] != null) or (multi_x >= 0 and multi_x < grid.size() and multi_y + i < grid[multi_x].size() and multi_y + i >= 0 and grid[multi_x][multi_y + i] != null) or (multi_x >= 0 and multi_x < grid.size() and multi_y - i >= 0 and multi_y - i < grid[multi_x].size() and grid[multi_x][multi_y - i] != null):
					around = true
					break
			
			if grid[multi_x][multi_y] == null:
				if around == false:
					var house_instance: StaticBody2D = house.instantiate()
					house_instance.set_position(tile_size * new_pos)
					grid[multi_x][multi_y] = OBSTACLE
					$"../Resources".add_child(house_instance)
					var mini_map_node: SubViewport = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
					mini_map_node.update_resources()
					Game.gold_mine_count += 1
					Game.stone -= cost
					Game.wood -= cost
