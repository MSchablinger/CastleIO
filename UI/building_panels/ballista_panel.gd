extends Panel

var house: PackedScene = preload("res://Buildings/ballista.tscn")

func _on_gui_input(event: InputEvent) -> void:
	var cost = 10 * (Game.gold_mine_count + 1)
	print(cost)
	if Game.wood >= cost and Game.stone >= cost and Game.gold >= cost:
		var house_instance: StaticBody2D = house.instantiate()

		if event is InputEventMouseButton and event.button_mask == 1:
			
			add_child(house_instance)
			house_instance.global_position = event.global_position
			#tempTower.process_mode = Node.PROCESS_MODE_DISABLED
			
			house_instance.scale = Vector2(0.32,0.32)
		
		elif event is InputEventMouseMotion and event.button_mask == 1:
			#button left down and dragging
			if get_child_count() > 1:
				get_child(1).global_position = event.global_position
				var targets = get_child(1).get_node("Area2D").get_overlapping_bodies()
				if (targets.size() > 1):
					get_child(1).get_node("Area2D").modulate = Color(255,255,255)
				else:
					get_child(1).get_node("Area2D").modulate = Color(0,255,0)
		elif event is InputEventMouseButton and event.button_mask == 0:
			#button left release
			if event.global_position.x <= 0 and event.global_position.x >= 1024:
				if get_child_count() > 1:
					get_child(1).queue_free()
			else:
				if get_child_count() > 1:
					get_child(1).queue_free()
				var targets = get_child(1).get_node("Area2D").get_overlapping_bodies()
				var path = get_tree().get_root().get_node("World/Houses")
				if (targets.size() < 2):
					path.add_child(house_instance)
					house_instance.position = event.global_position
					house_instance.get_node("Area2D").hide()
					var mini_map_node: SubViewport = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
					mini_map_node.update_resources()
					Game.gold_mine_count += 1
					Game.stone -= cost
					Game.wood -= cost
		else:
			if get_child_count() > 1:
				get_child(1).queue_free()
