extends CharacterBody2D


var speed : int = 100
var direction : Vector2

func _ready():
	var dist = Vector2(520, 392) - position
	if abs(dist.x) > abs(dist.y):
		direction.x = dist.x
		direction.y = 0
	else:
		#move vertically
		direction.x = 0
		direction.y = dist.y

func _physics_process(_delta):
	$AnimatedSprite2D.animation = "down"
	$AnimatedSprite2D.play()
	direction = Vector2(520, 392) - position
	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	if velocity.x != 0:
			$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		pass
