extends CharacterBody2D


var speed : int = 100
var direction : Vector2

func _physics_process(_delta):
	direction = Vector2(520, 392) - position
	direction = direction.normalized()
	print(direction)
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
