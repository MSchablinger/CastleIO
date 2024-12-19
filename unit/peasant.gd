extends CharacterBody2D

@export var speed: float = 100.0  # Movement speed of the enemy
@export var attack_damage: int = 10  # Damage dealt to the building per attack
@export var attack_interval: float = 1.0  # Time between attacks (in seconds)

# Internal variables
var target_position: Vector2
var can_attack: bool = true

# Reference to the building (StaticBody2D)
@onready var building = get_parent().get_node("Houses/CastleKeep")  # Adjust the path as needed

func _ready():
	target_position = building.global_position

func _physics_process(delta: float):
	var direction = (target_position - global_position).normalized()
	if not is_close_to_target():
		velocity = direction * speed
		if direction.y == 0:
			if direction.x > 0:
				$AnimatedSprite2D.animation = "right"
			elif direction.x < 0:
				$AnimatedSprite2D.animation = "left"
			else:
				$AnimatedSprite2D.animation = "idle"
		elif direction.x == 0:
			if direction.y > 0:
				$AnimatedSprite2D.animation = "up"
			elif direction.y < 0:
				$AnimatedSprite2D.animation = "down"
			else:
				$AnimatedSprite2D.animation = "idle"
		else:
			if abs(direction.x) > abs(direction.y):
				if direction.x > 0:
					$AnimatedSprite2D.animation = "right"
				else:
					$AnimatedSprite2D.animation = "left"
			else:
				if direction.y > 0:
					$AnimatedSprite2D.animation = "down"
				else:
					$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.play()	
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.animation = "idle"
		if can_attack:
			if direction.y == 0:
				if direction.x > 0:
					$AnimatedSprite2D.animation = "attack_right"
				elif direction.x < 0:
					$AnimatedSprite2D.animation = "attack_left"
				else:
					$AnimatedSprite2D.animation = "idle"
			elif direction.x == 0:
				if direction.y > 0:
					$AnimatedSprite2D.animation = "attack_up"
				elif direction.y < 0:
					$AnimatedSprite2D.animation = "attack_down"
				else:
					$AnimatedSprite2D.animation = "idle"
			else:
				if abs(direction.x) > abs(direction.y):
					if direction.x > 0:
						$AnimatedSprite2D.animation = "attack_right"
					else:
						$AnimatedSprite2D.animation = "attack_left"
				else:
					if direction.y > 0:
						$AnimatedSprite2D.animation = "attack_down"
					else:
						$AnimatedSprite2D.animation = "attack_up"
			attack_building()

func is_close_to_target() -> bool:
	return global_position.distance_to(target_position) < 40.0  # Adjust the distance as needed

func attack_building():
	if building != null and not building.is_queued_for_deletion() and building.has_method("apply_damage"):
		building.apply_damage(attack_damage)
		can_attack = false
		await get_tree().create_timer(attack_interval).timeout
		can_attack = true
