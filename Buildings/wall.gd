extends StaticBody2D

var level: int = 1
var max_level: int = 3
var health: float = 100.0
var is_being_attacked: bool = false

@onready var sprite = $WallSprite
@onready var progress_bar = $ProgressBar

func _ready():
	print("Wall initialized, adding to walls group")
	add_to_group("walls")
	progress_bar.max_value = health
	progress_bar.value = health
	update_appearance()

func apply_damage(damage: int):
	print("Wall taking damage: ", damage, " Current health: ", health)
	is_being_attacked = true
	health -= damage
	progress_bar.value = health
	# Flash red when taking damage
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	is_being_attacked = false
	print("Wall health after damage: ", health)
	if health <= 0:
		print("Wall destroyed")
		# Notify attackers that wall is destroyed
		for attacker in get_tree().get_nodes_in_group("enemies"):
			if attacker.building == self:
				attacker.reset_target()
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
