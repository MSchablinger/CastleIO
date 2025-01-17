extends Area2D

enum ChestType { NORMAL, GOLD }

var type: ChestType
var gold_amount: int
var despawn_time := 15.0 # in seconds

func _ready() -> void:
	input_event.connect(_on_input_event)
	var timer = get_tree().create_timer(despawn_time)
	timer.timeout.connect(queue_free)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_delay(despawn_time - 1.0)

func init(chest_type: ChestType) -> void:
	type = chest_type
	$Sprite2D.frame = type
	
	if type == ChestType.NORMAL:
		gold_amount = randi_range(5, 50)
	else:
		gold_amount = randi_range(50, 250)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		collect()

func collect() -> void:
	Game.gold += gold_amount
	queue_free()
