extends "res://UI/building_panels/building_panel.gd"

var house: PackedScene = preload("res://Buildings/ballista.tscn")

func _ready():
	super._ready()
	building_name = "Ballista Tower"
	var cost = 10 * (Game.gold_mine_count + 1)
	wood_cost = cost
	stone_cost = cost
	gold_cost = cost
	description = "Defensive tower that shoots at enemies.\nDamage: 10\nRange: 200"

func _on_gui_input(event: InputEvent) -> void:
	var cost = 10 * (Game.gold_mine_count + 1)
	print(cost)
	if Game.wood >= cost and Game.stone >= cost and Game.gold >= cost:
		var house_instance: StaticBody2D = house.instantiate()
		var camera = get_tree().get_root().get_node("World/Camera")
		var world_pos = camera.get_global_mouse_position()
		if event is InputEventMouseButton and event.button_mask == 1:
			add_child(house_instance)
			house_instance.global_position = world_pos
			house_instance.scale = Vector2(2, 2)
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
			if world_pos.x <= 0 and world_pos.x >= 1024:
				if get_child_count() > 1:
					get_child(1).queue_free()
			else:
				if get_child_count() > 1:
					get_child(1).queue_free()
				var targets = get_child(1).get_node("Area2D").get_overlapping_bodies()
				var path = get_tree().get_root().get_node("World/Houses")
				if (targets.size() < 2):
					path.add_child(house_instance)
					house_instance.position = world_pos
					house_instance.get_node("Area2D").hide()
					var mini_map_node: SubViewport = get_tree().get_root().get_node("World/UI/MiniMap/SubViewportContainer/SubViewport")
					mini_map_node.update_resources()
					Game.gold_mine_count += 1
					Game.stone -= cost
					Game.wood -= cost
		else:
			if get_child_count() > 1:
				get_child(1).queue_free()
