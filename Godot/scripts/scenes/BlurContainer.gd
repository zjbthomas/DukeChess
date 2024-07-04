extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	# always hide as default when loaded
	hide()
	$WrapperWindow.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate():
	show()
	$WrapperWindow.popup_centered()
	
func complete():
	hide()
	$WrapperWindow.unload_window()
