extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collection_button_pressed():
	$BlurContainer/WrapperWindow.load_window("collection")
	$BlurContainer/WrapperWindow.get_loaded_window().ok_button_pressed.connect(func(): $BlurContainer.complete())
	$BlurContainer.activate()
