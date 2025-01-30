extends Node2D

signal keep_destroyed

@onready var progress_bar = $ProgressBar

func apply_damage(damage: int):
	progress_bar.value -= damage
	if progress_bar.value <= 0:
		keep_destroyed.emit()
		queue_free()

func heal(amount: int):
	if progress_bar.value < progress_bar.max_value:
		progress_bar.value += amount
		progress_bar.value = min(progress_bar.value, progress_bar.max_value)
