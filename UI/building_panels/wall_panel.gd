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
	for other_wall in walls:
		if other_wall != wall:
			var distance = wall.position.distance_to(other_wall.position)
			if distance <= GRID_SIZE:
				# They're adjacent, update sprites based on relative positions
				update_wall_sprite(wall, other_wall)
				update_wall_sprite(other_wall, wall)

func update_wall_sprite(wall: Node2D, adjacent: Node2D):
	var sprite = wall.get_node("WallSprite")
	var relative_pos = adjacent.position - wall.position
	
	# Update frame based on relative position
	if relative_pos.x > 0:  # Adjacent wall is to the right
		sprite.frame = 1
	elif relative_pos.x < 0:  # Adjacent wall is to the left
		sprite.frame = 1
	elif relative_pos.y > 0:  # Adjacent wall is below
		sprite.frame = 2
	elif relative_pos.y < 0:  # Adjacent wall is above
		sprite.frame = 2
