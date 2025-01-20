extends CharacterBody2D

var speed: float = 50.0  # Movement speed of the enemy
var attack_damage: int = 5  # Damage dealt to the building per attack
var attack_interval: float = 1.0  # Time between attacks
var health = 100
var keep: Node  # Store reference to keep

# Internal variables
var target_position: Vector2
var can_attack: bool = true

# Reference to the building (StaticBody2D)
@onready var building = get_parent().get_parent().get_node("Houses/CastleKeep")
@onready var animation_sprite = $AnimatedSprite2D 
@onready var navigation = $NavigationAgent2D
@onready var progress_bar = $ProgressBar
@onready var attack_timer = $AttackTimer

func _ready():
	add_to_group("enemies")
	keep = get_parent().get_parent().get_node("Houses/CastleKeep")
	building = keep
	if building:
		target_position = building.global_position

func reset_target():
	building = keep
	target_position = keep.global_position
	navigation.target_position = target_position

func _physics_process(_delta: float):
	if building == null:
		reset_target()
		return

	# First check if we need to find a wall to break through
	var walls = get_tree().get_nodes_in_group("walls")
	var closest_wall = null
	var closest_distance = INF
	
	# Only look for walls if we're targeting the keep
	if building == keep:
		for wall in walls:
			var distance = global_position.distance_to(wall.global_position)
			# Check if wall is blocking path to keep
			var to_keep = (keep.global_position - global_position)
			var to_wall = (wall.global_position - global_position)
			if distance < closest_distance and distance < to_keep.length():
				closest_distance = distance
				closest_wall = wall
	
	# If we found a wall in our path and we're close enough, attack it
	if closest_wall and closest_distance < 100:
		building = closest_wall
		target_position = closest_wall.global_position
		# print("Targeting wall at distance: ", closest_distance)
		navigation.target_position = target_position
		
		if navigation.is_navigation_finished():
			velocity = Vector2.ZERO
			play_animation("idle")
			if can_attack and is_close_to_target():
				# print("Attempting to attack building")
				attack_building()
		else:
			move_along_path()
	elif building != null and not building.is_queued_for_deletion():
		# print("Current target: ", building.name, " at position: ", building.global_position)
		navigation.target_position = building.global_position
		if navigation.is_navigation_finished():
			velocity = Vector2.ZERO
			play_animation("idle")
			if can_attack and is_close_to_target():
				# print("Attempting to attack building")
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
	# print("Attack building called. Building: ", building)
	if building != null and not building.is_queued_for_deletion() and building.has_method("apply_damage"):
		# print("Dealing damage to building")
		building.apply_damage(attack_damage)
		play_animation(get_attack_animation())
		can_attack = false
		attack_timer.start(attack_interval)

func is_close_to_target() -> bool:
	var distance = global_position.distance_to(building.global_position)
	# print("Distance to target: ", distance)
	return distance < 60.0  # Increased attack range

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

func _on_attack_timer_timeout():
	can_attack = true
