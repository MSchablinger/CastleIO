extends CharacterBody2D

var speed: float = 100.0  # Movement speed of the enemy
var attack_damage: int = 10  # Damage dealt to the building per attack
var attack_interval: float = 3.0  # Time between attacks (in seconds)
var health = 100

# Internal variables
var target_position: Vector2
var can_attack: bool = true

# Reference to the building (StaticBody2D)
@onready var building = get_parent().get_parent().get_node("Houses/CastleKeep")
@onready var animation_sprite = $AnimatedSprite2D 
@onready var navigation = $NavigationAgent2D
@onready var progress_bar = $ProgressBar

func _ready():
	if building:
		target_position = building.global_position

func _physics_process(_delta: float):
	if building != null and not building.is_queued_for_deletion():
		navigation.target_position = building.global_position
	else:
		# Look for nearby walls if no building target
		var walls = get_tree().get_nodes_in_group("walls")
		var closest_wall = null
		var closest_distance = INF
		
		for wall in walls:
			var distance = global_position.distance_to(wall.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_wall = wall
		
		if closest_wall and closest_distance < 100:  # Attack range
			building = closest_wall
			target_position = closest_wall.global_position
	if navigation.is_navigation_finished():
		velocity = Vector2.ZERO
		play_animation("idle")
		if can_attack and is_close_to_target():
			attack_building()
	else:
		move_along_path()

func apply_damage(damage: int):
	progress_bar.value -= damage
	if progress_bar.value <= 0:
		queue_free()

func move_along_path():
	var next_point = navigation.get_next_path_position()
	if global_position.distance_to(next_point) > 1.0:
		var direction = (next_point - global_position).normalized()
		velocity = direction * speed
		play_movement_animation(direction)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func attack_building():
	if building != null and not building.is_queued_for_deletion() and building.has_method("apply_damage"):
		building.apply_damage(attack_damage)
		play_animation(get_attack_animation())
		can_attack = false
		await get_tree().create_timer(attack_interval).timeout
		can_attack = true

func is_close_to_target() -> bool:
	return global_position.distance_to(target_position) < 40.0

func play_animation(animation_name: String):
	if animation_sprite.animation != animation_name:
		animation_sprite.play(animation_name)

func play_movement_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			play_animation("right")
		else:
			play_animation("left")
	else:
		if direction.y > 0:
			play_animation("down")
		else:
			play_animation("up")

func get_attack_animation() -> String:
	if abs(velocity.x) > abs(velocity.y):
		return "attack_right" if velocity.x > 0 else "attack_left"
	else:
		return "attack_down" if velocity.y > 0 else "attack_up"

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		apply_damage(10)
