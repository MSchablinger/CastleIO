extends Node2D

@export var velocity: Vector2 = Vector2.ZERO
@export var lifetime: float = 5.0

func _ready():
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", self.queue_free)
	add_child(timer)
	timer.start()

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.name == "Peasant":
		body.apply_damage(10) # Call enemy's damage function
		queue_free()
