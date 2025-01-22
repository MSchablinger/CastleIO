extends StaticBody2D

# Export variables for customization
@export var projectile_scene = preload("res://Entities/bolt.tscn")
@export var fire_rate: float = 1.0
@export var projectile_speed: float = 400.0

# Internal variables
var enemies_in_range = []
var fire_timer: Timer
var current_target = null

func _ready():
	# Initialize timer
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.autostart = true
	fire_timer.one_shot = false
	fire_timer.connect("timeout", self._on_fire_timer_timeout)
	add_child(fire_timer)

func _process(_delta):
	update_enemies_in_range()
	update_sprite_direction()

func update_enemies_in_range():
	enemies_in_range.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			if position.distance_to(enemy.global_position) <= 200:
				enemies_in_range.append(enemy)

func update_sprite_direction():
	current_target = get_nearest_enemy()
	if current_target:
		var direction = position.direction_to(current_target.global_position)
		var angle = direction.angle()
		
		# Convert angle to sprite frame
		# Normalize angle to 0-2PI range
		angle = fmod(angle + 2 * PI, 2 * PI)
		
		# Select appropriate frame based on angle
		if angle < PI/4 or angle > 7*PI/4:  # Right
			$BallistaSprite.frame = 15
		elif angle < 3*PI/4:  # Down
			$BallistaSprite.frame = 8
		elif angle < 5*PI/4:  # Left
			$BallistaSprite.frame = 22
		else:  # Up
			$BallistaSprite.frame = 0

func _on_fire_timer_timeout():
	if enemies_in_range.size() > 0:
		shoot_projectile()

func shoot_projectile():
	current_target = get_nearest_enemy()
	if not current_target:
		return
	
	var projectile = projectile_scene.instantiate()
	var direction = position.direction_to(current_target.global_position)
	
	var units_node = get_tree().get_root().get_node("World/Units")
	units_node.add_child(projectile)
	
	# Offset the spawn position based on ballista sprite
	var spawn_offset = Vector2(0, -16)
	projectile.global_position = global_position + spawn_offset
	
	# Set bolt sprite frame and rotation
	var angle = direction.angle()
	projectile.get_node("Sprite2D").frame = 1 if abs(angle) > PI/2 else 0
	projectile.rotation = direction.angle()
	projectile.velocity = direction * projectile.speed

func get_nearest_enemy() -> Node2D:
	var nearest = null
	var shortest_distance = INF
	for enemy in enemies_in_range:
		if is_instance_valid(enemy):
			var distance = position.distance_to(enemy.position)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest = enemy
	return nearest
