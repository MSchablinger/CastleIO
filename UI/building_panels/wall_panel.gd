extends Panel

var house: PackedScene = preload("res://Buildings/wall.tscn")

func _on_gui_input(event: InputEvent) -> void:
    var cost = 5 # Base wall cost

    if Game.wood >= cost and Game.stone >= cost:
        var house_instance: StaticBody2D = house.instantiate()

        if event is InputEventMouseButton and event.button_mask == 1:
            add_child(house_instance)
            house_instance.global_position = event.global_position
            house_instance.scale = Vector2(1, 1)
        
        elif event is InputEventMouseMotion and event.button_mask == 1:
            if get_child_count() > 1:
                get_child(1).global_position = event.global_position
                var targets = get_child(1).get_node("Area2D").get_overlapping_bodies()
                if (targets.size() > 1):
                    get_child(1).get_node("Area2D").modulate = Color(255,255,255)
                else:
                    get_child(1).get_node("Area2D").modulate = Color(0,255,0)
        
        elif event is InputEventMouseButton and event.button_mask == 0:
            if get_child_count() > 1:
                get_child(1).queue_free()
                var targets = get_child(1).get_node("Area2D").get_overlapping_bodies()
                var path = get_tree().get_root().get_node("World/Houses")
                if (targets.size() < 2):
                    path.add_child(house_instance)
                    house_instance.position = event.global_position
                    house_instance.get_node("Area2D").hide()
                    Game.stone -= cost
                    Game.wood -= cost
        else:
            if get_child_count() > 1:
                get_child(1).queue_free()
