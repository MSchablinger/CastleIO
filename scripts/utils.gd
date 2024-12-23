extends Node2D

func get_random_positions(amount: int) -> Array:
	var positions: Array = []
	for i: int in range(amount):
		var x_coor: int = randi() % int(Game.grid_size.x)
		var y_coor: int = randi() % int(Game.grid_size.y)
		var grid_position: Vector2i = Vector2i(x_coor, y_coor)
		if not grid_position in positions:
			positions.append(grid_position)
	return positions
