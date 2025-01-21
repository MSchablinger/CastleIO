extends StaticBody2D

# Export variables for customization
@export var projectile_scene = preload("res://Entities/bolt.tscn")
@export var fire_rate: float = 1.0
@export var projectile_speed: float = 400.0

# Internal variables
var enemies_in_range = []
var fire_timer: Timer

func _ready():
	# Initialize timer
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.autostart = true
	fire_timer.one_shot = false
	fire_timer.connect("timeout", self._on_fire_timer_timeout)
	add_child(fire_timer)

func _process(delta):
	update_enemies_in_range()

func update_enemies_in_range():
	enemies_in_range.clear()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			if global_position.distance_to(enemy.global_position) <= 500:
				enemies_in_range.append(enemy)

func _on_fire_timer_timeout():
	if enemies_in_range.size() > 0:
		shoot_projectile()

func shoot_projectile():
	# Get the nearest enemy
	var nearest_enemy = get_nearest_enemy()
	if not nearest_enemy:
		return
	
	# Create and launch projectile
	var projectile = projectile_scene.instantiate()
	projectile.position = global_position
	var direction = (nearest_enemy.global_position - global_position).normalized()
	projectile.rotation = direction.angle()
	add_child(projectile)
	
	# Give the projectile velocity
	projectile.velocity = direction * projectile_speed

func get_nearest_enemy() -> Node2D:
	var nearest = null
	var shortest_distance = INF
	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest = enemy
	return nearest
