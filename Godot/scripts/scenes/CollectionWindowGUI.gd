extends ColorRect

@export var chess_in_show_scene:PackedScene

signal ok_button_pressed

@onready var chess_container = $VBoxContainer/ScrollContainer/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	for chess in Global.chess_loader.chess_name_list:
		var node = chess_in_show_scene.instantiate()
		chess_container.add_child(node)
		node.setup_ui(chess)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_ok_button_pressed():
	ok_button_pressed.emit()
