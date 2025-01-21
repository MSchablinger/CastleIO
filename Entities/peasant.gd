extends CharacterBody2D

# Constants and variables
var speed: float = 50.0
var attack_damage: int = 5
var attack_interval: float = 1.0
var health = 100
var keep: Node

var target_position: Vector2
var can_attack: bool = true

@onready var building = null
@onready var animation_sprite = $AnimatedSprite2D
@onready var navigation = $NavigationAgent2D
@onready var progress_bar = $ProgressBar
@onready var attack_timer = $AttackTimer

func _ready():
	add_to_group("enemies")
	keep = get_parent().get_parent().get_node("Houses/CastleKeep")
	reset_target()

func reset_target():
	if keep and not keep.is_queued_for_deletion():
		building = keep
		target_position = keep.global_position
		navigation.target_position = target_position

func _physics_process(_delta: float):
	if not building or building.is_queued_for_deletion():
		reset_target()
		return

	# Look for walls if targeting the keep
	if building == keep:
		var closest_wall = find_closest_wall()
		if closest_wall:
			building = closest_wall
			target_position = closest_wall.global_position
			navigation.target_position = target_position

	# Handle navigation and actions
	handle_navigation()

func find_closest_wall() -> Node:
	var walls = get_tree().get_nodes_in_group("walls")
	if walls.is_empty():
		return null

	var closest_wall = null
	var closest_distance = INF

	for wall in walls:
		if not wall or wall.is_queued_for_deletion():
			continue
		var distance = global_position.distance_to(wall.global_position)
		var to_keep = keep.global_position - global_position
		var to_wall = wall.global_position - global_position
		# Ensure the wall is blocking the path
		if distance < closest_distance and distance < to_keep.length():
			closest_distance = distance
			closest_wall = wall

	# Only return walls within a reasonable range
	return closest_wall if closest_distance < 100 else null

func handle_navigation():
	if navigation.is_navigation_finished():
		velocity = Vector2.ZERO
		play_animation("idle")
		if can_attack:
			attack_building()
	else:
		move_along_path()

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
	if building and not building.is_queued_for_deletion() and building.has_method("apply_damage"):
		building.apply_damage(attack_damage)
		play_animation(get_attack_animation())
		can_attack = false
		attack_timer.start(attack_interval)

func play_animation(animation_name: String):
	if animation_sprite.animation != animation_name:
		animation_sprite.play(animation_name)

func play_movement_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		play_animation("right" if direction.x > 0 else "left")
	else:
		play_animation("down" if direction.y > 0 else "up")

func get_attack_animation() -> String:
	return "attack_right" if velocity.x > 0 else "attack_left" if abs(velocity.x) > abs(velocity.y) else "attack_down" if velocity.y > 0 else "attack_up"

func apply_damage(damage: int):
	progress_bar.value -= damage
	if progress_bar.value <= 0:
		queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		apply_damage(10)

func _on_attack_timer_timeout():
	can_attack = true
