extends Node2D
@onready var progress_bar = $ProgressBar

func apply_damage(damage: int):
	progress_bar.value -= damage
	if progress_bar.value <= 0:
		queue_free()
