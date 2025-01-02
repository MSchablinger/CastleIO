extends Control

signal retry_pressed

func _ready():
	hide()

func show_game_over():
	show()
	get_tree().paused = true

func _on_retry_button_pressed():
	get_tree().paused = false
	retry_pressed.emit()
