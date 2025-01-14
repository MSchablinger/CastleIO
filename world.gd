extends Node2D

var units: Array = []
@onready var game_over_ui = $GameOver
@onready var castle_keep = $Houses/CastleKeep
@onready var units_node = $Units
@onready var next_wave = $NextWave

func _ready():
	get_units()
	castle_keep.keep_destroyed.connect(_on_keep_destroyed)
	game_over_ui.retry_pressed.connect(_on_retry_pressed)
	units_node.wave_cleared.connect(_on_wave_cleared)

func _on_wave_cleared():
	next_wave.show_wave()

func _on_keep_destroyed():
	game_over_ui.show_game_over()

func _on_retry_pressed():
	# Reset resources
	Game.wood = 0
	Game.stone = 0
	Game.gold = 0
	Game.gold_mine_count = 0

	# Make sure we're unpaused before changing the scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://world.tscn")

func get_units() -> void:
	units = get_tree().get_nodes_in_group("units")


func _on_area_selected(object):
	var start = object.start
	var end = object.end
	var area: Array = []
	area.append(Vector2(min(start.x, end.x), min(start.y, end.y)))
	area.append(Vector2(max(start.x, end.x), max(start.y, end.y)))
	var units_selected: Array = get_units_in_area(area)
	
	deselect_all_units()
		
	for unit in units_selected:
		unit.set_selected(!unit.selected)


func deselect_all_units():
	for unit in units:
		unit.set_selected(false)


func get_units_in_area(area: Array):
	var _units: Array = []
	for unit in units:
		if (unit.position.x > area[0].x) and (unit.position.x < area[1].x):
			if (unit.position.y > area[0].y) and (unit.position.y < area[1].y):
				_units.append(unit)
	
	return _units
