extends Control

@onready var label = get_node("Panel/Label")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
 
func show_wave():
	show()
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	get_tree().paused = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	label.text = "Wave " + str(Game.wave)
