extends Panel

@onready var label = $ContentPanel/Label
@onready var content_panel = $ContentPanel

func _ready():
    hide()

func show_at_position(pos: Vector2, text: String):
    # Set text first so we can get the proper size
    label.text = text
    
    # Wait a frame for the text to update
    await get_tree().process_frame
    
    # Get the required height and update minimum size
    var required_height = label.get_content_height() + 20  # Add padding
    custom_minimum_size.y = required_height
    
    # Position 5px above the panel
    position = Vector2(pos.x, pos.y - size.y - 5)
    
    show()
