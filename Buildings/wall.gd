extends StaticBody2D

var Level: int = 1
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
	if Level < max_level:
		Level += 1
		health += 50  # More health per level
		progress_bar.max_value = health
		progress_bar.value = health
		update_appearance()
		return true
	return false

func update_appearance():
	var texture_path = "res://Assets/GodsBuildings/Walls/Lvl%02d.png" % Level
	print("Loading wall texture: ", texture_path)
	var new_texture = load(texture_path)
	if new_texture:
		print("Successfully loaded texture")
		sprite.texture = new_texture
		sprite.region_enabled = false # Disable region mode
		
		# Level 1 is 48x32 (3x2), Levels 2 and 3 are 48x96 (3x6)
		if Level == 1:
			sprite.hframes = 3
			sprite.vframes = 2
		else:
			sprite.hframes = 3
			sprite.vframes = 6
			
	else:
		push_error("Failed to load wall texture: " + texture_path)

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:  # Right click to upgrade
			var upgrade_cost = 10 * Level  # Increasing cost per level
			if Game.wood >= upgrade_cost and Game.stone >= upgrade_cost:
				if upgrade():
					Game.wood -= upgrade_cost
					Game.stone -= upgrade_cost
