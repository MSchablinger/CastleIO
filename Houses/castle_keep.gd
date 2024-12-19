extends Node2D
@onready var progress_bar = $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress_bar.value = Game.health
	pass

func apply_damage(damage: int):
	Game.health -= damage
	if Game.health <= 0:
		die()
func die():
	queue_free()
