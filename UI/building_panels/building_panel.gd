extends Panel

var tooltip: Panel

@export var building_name: String = "Building"
@export var wood_cost: int = 0
@export var stone_cost: int = 0 
@export var gold_cost: int = 0
@export var description: String = "Building description"

func _ready():
    tooltip = get_node("/root/World/UI/Tooltip")
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
    var text = "[center][b]%s[/b][/center]\n\n" % building_name
    text += "[b]Cost:[/b]\n"
    if wood_cost > 0:
        text += "• Wood: %d\n" % wood_cost
    if stone_cost > 0:
        text += "• Stone: %d\n" % stone_cost
    if gold_cost > 0:
        text += "• Gold: %d\n" % gold_cost
    text += "\n%s" % description
    
    if not can_afford():
        text += "\n\n[color=red][b]Not enough resources![/b][/color]"
    
    var panel_pos = get_global_position()
    tooltip.show_at_position(panel_pos + Vector2(0, -20), text)

func _on_mouse_exited():
    tooltip.hide()

func can_afford() -> bool:
    return Game.wood >= wood_cost and Game.stone >= stone_cost and Game.gold >= gold_cost
