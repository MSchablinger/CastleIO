extends StaticBody2D

@export var heal_amount: int = 20

func _ready():
	$Sprite2D.frame = randi() % 3 + 3  # Random frame 3-5 (6)
	$Area2D.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		var keep = get_node_or_null("/root/World/Houses/CastleKeep")
		if keep:
			keep.heal(heal_amount)
			queue_free()
