extends CharacterBody2D

@export var lifetime: float = 5.0
@export var damage: int = 10
@export var speed: float = 400.0

func _ready():
	print("Bolt spawned")
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", self._on_timer_timeout)
	add_child(timer)
	timer.start()

func _physics_process(_delta):
	var collision = move_and_collide(velocity * _delta)
	if collision:
		var collider = collision.get_collider()
		if collider.is_in_group("enemies"):
			print("Direct collision with enemy")
			collider.apply_damage(damage)
		queue_free()

func _on_area_2d_body_entered(body):
	print("Area entered by: ", body.name)
	if body.is_in_group("enemies"):
		print("Hit enemy: ", body.name)
		body.apply_damage(damage)
		queue_free()

func _on_area_2d_area_entered(area):
	print("Bolt hit area: ", area.get_parent().name)
	var parent = area.get_parent()
	if parent.is_in_group("enemies"):
		parent.apply_damage(damage)
		queue_free()

func _on_timer_timeout():
	queue_free()
