extends StaticBody2D

var level: int = 1
var max_level: int = 3
var health: float = 100.0

@onready var sprite = $WallSprite
@onready var progress_bar = $ProgressBar

func _ready():
	add_to_group("walls")
	progress_bar.max_value = health
	progress_bar.value = health
	update_appearance()

func apply_damage(damage: int):
	health -= damage
	progress_bar.value = health
	if health <= 0:
		queue_free()

func upgrade():
	if level < max_level:
		level += 1
		health += 50  # More health per level
		progress_bar.max_value = health
		progress_bar.value = health
		update_appearance()
		return true
	return false

func update_appearance():
	sprite.texture = load("res://Assets/GodsBuildings/Walls/Lvl0%d.png" % level)
	sprite.hframes = 3
	sprite.vframes = 2 if level == 1 else 6  # Lvl01 is 3x2, others are 3x6
	sprite.frame = 0  # Always show first frame

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:  # Right click to upgrade
			var upgrade_cost = 10 * level  # Increasing cost per level
			if Game.wood >= upgrade_cost and Game.stone >= upgrade_cost:
				if upgrade():
					Game.wood -= upgrade_cost
					Game.stone -= upgrade_cost
