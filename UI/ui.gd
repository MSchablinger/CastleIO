extends CanvasLayer

@onready var wood_label: Label = $ResourceContainer/WoodRow/WoodLabel
@onready var stone_label: Label = $ResourceContainer/StoneRow/StoneLabel
@onready var gold_label: Label = $ResourceContainer/GoldRow/GoldLabel

func _process(_delta):
	wood_label.text = "Wood: " + str(Game.wood)
	stone_label.text = "Stone: " + str(Game.stone)
	gold_label.text = "Gold: " + str(Game.gold)
