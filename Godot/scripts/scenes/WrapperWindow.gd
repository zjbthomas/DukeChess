extends Window

var _loaded_gui

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func load_window(name):
	_loaded_gui = load(Global.WINDOW_TYPE.get(name)).instantiate()
	add_child(_loaded_gui)
	
	# set size
	size = _loaded_gui.size

func unload_window():
	hide()
	remove_child(_loaded_gui) # we need this as queue_free() is not performed immediately
	_loaded_gui.queue_free()

func get_loaded_window():
	return _loaded_gui
