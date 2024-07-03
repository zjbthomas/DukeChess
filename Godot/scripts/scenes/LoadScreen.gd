extends ColorRect

@export var main_scene: PackedScene

var _is_loading_smooth = true

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_game_resources()
	
	if (_is_loading_smooth):
		get_tree().change_scene_to_packed(main_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _load_game_resources():
	$VBoxContainer/ProgressBar.value = 0

	# load chess
	Global.chess_loader = ChessLoader.new()
	Global.chess_loader.connect("error_message", _on_chess_loader_error_message)
	
	Global.chess_loader.load_chess()
	
	# finish loading
	$VBoxContainer/ProgressBar.value = 100

func _on_chess_loader_error_message(msg):
	$VBoxContainer/Label.text = msg
	
	_is_loading_smooth = false
