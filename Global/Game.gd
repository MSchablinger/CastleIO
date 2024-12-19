extends Node

var wood: int = 0
var stone: int = 0
var gold: int = 0
var gold_mine_count: int = 0
var health: int = 100
var is_spawn_unit_open: bool = false

var tile_size: int = 16
var grid_size: Vector2i = Vector2i(64, 48)

@onready var spawn: PackedScene = preload("res://Global/spawn_unit.tscn")

func spawn_unit(position: Vector2) -> void:
	if is_spawn_unit_open:
		return
	
	var ui_node: CanvasLayer = get_tree().get_root().get_node("World/UI")
	var spawn_instance: Node2D = spawn.instantiate()
	spawn_instance.house_position = position
	ui_node.add_child(spawn_instance)
	is_spawn_unit_open = true


func close_spawn_unit() -> void:
	is_spawn_unit_open = false
