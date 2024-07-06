extends PanelContainer

signal on_button_pressed(item)

@onready var container = $MarginContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_buttons(items):
	for item in items:
		var node = Button.new()
		node.text = item
		
		node.connect("pressed", _on_button_pressed.bind(node))
		
		container.add_child(node)

func _on_button_pressed(node):
	on_button_pressed.emit(node.text)
