extends Panel

var house: PackedScene = preload("res://Buildings/wall.tscn")
const GRID_SIZE = 32  # Size of each grid cell (doubled)
var ghost_instance: StaticBody2D = null

func _on_gui_input(event: InputEvent) -> void:
	var cost = 5 # Base wall cost

	if Game.wood >= cost and Game.stone >= cost:
		var camera = get_tree().get_root().get_node("World/Camera")
		var world_pos = camera.get_global_mouse_position()
		var path = get_tree().get_root().get_node("World/Houses")

		if event is InputEventMouseButton and event.button_mask == 1:
			# Create ghost on mouse down
			ghost_instance = house.instantiate()
			path.add_child(ghost_instance)
			ghost_instance.modulate = Color(1, 1, 1, 0.5)  # Make it semi-transparent
			var grid_pos = snap_to_grid(world_pos)
			ghost_instance.position = grid_pos
		
		elif event is InputEventMouseMotion and event.button_mask == 1:
			if ghost_instance:
				var grid_pos = snap_to_grid(world_pos)
				ghost_instance.position = grid_pos
				var can_place = true
				# Check for overlapping walls
				for wall in path.get_children():
					if wall != ghost_instance and wall.position.distance_to(grid_pos) < GRID_SIZE/2:
						can_place = false
						break
				
				if can_place:
					ghost_instance.modulate = Color(0, 1, 0, 0.5)  # Green if can place
				else:
					ghost_instance.modulate = Color(1, 0, 0, 0.5)  # Red if can't place
		
		elif event is InputEventMouseButton and event.button_mask == 0:
			if ghost_instance:
				var grid_pos = snap_to_grid(world_pos)
				var can_place = true
				
				# Check for overlapping walls
				for wall in path.get_children():
					if wall != ghost_instance and wall.position.distance_to(grid_pos) < GRID_SIZE/2:
						can_place = false
						break
				
				if can_place:
					var house_instance = house.instantiate()
					path.add_child(house_instance)
					house_instance.position = grid_pos
					house_instance.get_node("Area2D").hide()
					check_and_update_connections(house_instance)
					Game.stone -= cost
					Game.wood -= cost
				
				ghost_instance.queue_free()
				ghost_instance = null
	else:
		# Clean up ghost if we don't have resources
		if ghost_instance:
			ghost_instance.queue_free()
			ghost_instance = null

func snap_to_grid(pos: Vector2) -> Vector2:
	var x = round(pos.x / GRID_SIZE) * GRID_SIZE
	var y = round(pos.y / GRID_SIZE) * GRID_SIZE
	return Vector2(x, y)

func check_and_update_connections(wall: Node2D):
	var walls = get_tree().get_nodes_in_group("walls")
	var connected_walls = []
	
	print("Checking connections for wall at: ", wall.position)
	
	for other_wall in walls:
		if other_wall != wall:
			var distance = wall.position.distance_to(other_wall.position)
			if distance <= GRID_SIZE:
				connected_walls.append(other_wall)
				print("Found connected wall at: ", other_wall.position, " distance: ", distance)
	
	print("Total connected walls: ", connected_walls.size())
	# Update sprites based on all connections
	update_wall_sprite(wall, connected_walls)
	# Update adjacent walls
	for other_wall in connected_walls:
		var other_connected = walls.filter(func(w): 
			return w != other_wall and w != wall and w.position.distance_to(other_wall.position) <= GRID_SIZE
		)
		print("Updating connected wall at: ", other_wall.position, " with ", other_connected.size(), " connections")
		update_wall_sprite(other_wall, other_connected)

func update_wall_sprite(wall: Node2D, connected_walls: Array):
	var sprite = wall.get_node("WallSprite")
	var level = wall.Level
	
	# Default to corner piece
	if level == 1:
		sprite.frame = 3
	else:
		sprite.frame = 4
	
	if connected_walls.size() == 2:
		var pos1 = connected_walls[0].position - wall.position
		var pos2 = connected_walls[1].position - wall.position
		
		# Check if the walls form a straight line
		var is_horizontal = abs(pos1.y) < GRID_SIZE/2 and abs(pos2.y) < GRID_SIZE/2
		var is_vertical = abs(pos1.x) < GRID_SIZE/2 and abs(pos2.x) < GRID_SIZE/2
		
		# Check if the walls are on opposite sides
		var opposite_sides = (pos1.x * pos2.x < 0) or (pos1.y * pos2.y < 0)
		
		if level == 1:
			# Level 1 wall frames
			if is_horizontal and opposite_sides:
				# Left/right connection (frame 1x3)
				sprite.frame = 2
			elif is_vertical and opposite_sides:
				# Top/bottom connection (frame 2x3)
				sprite.frame = 5
		else:
			# Level 2 and 3 wall frames
			if is_horizontal and opposite_sides:
				# Left/right connection (frame 3x1)
				sprite.frame = 6
			elif is_vertical and opposite_sides:
				# Top/bottom connection (frame 3x2)
				sprite.frame = 7
