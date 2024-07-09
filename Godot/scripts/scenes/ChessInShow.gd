extends AspectRatioContainer

@onready var front_container = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer
@onready var front_name_label = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer/Name/NameLabel
@onready var front_side_image = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer/SideImage
@onready var front_center = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer/Center

@onready var back_container = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer
@onready var back_name_label = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer/Name/NameLabel
@onready var back_side_image = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer/SideImage
@onready var back_center = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer/Center

@onready var name_label = $VBoxContainer/HBoxContainer/NameLabel

signal chess_pressed(node)

const CENTER_X = 71
const CENTER_Y = 71
const OFFSET = 28

var chess

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ui_localization()

func _setup_ui_localization():
	$VBoxContainer/ChessInfoContainer/Front/FrontLabel.text = tr("CHESS_SHOW_FRONT")
	$VBoxContainer/ChessInfoContainer/Back/BackLabel.text = tr("CHESS_SHOW_BACK")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# TODO: this is similar to the one in Chess.gd, can we combine into one function?
func setup_ui():
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[chess]
	
	for is_front in [true, false]:
		# move center if necessary
		if (is_front):
			if (chess_model.front_center_offset_x != 0 or chess_model.front_center_offset_y != 0):
				front_center.position.x = CENTER_X + chess_model.front_center_offset_x * OFFSET
				front_center.position.y = CENTER_Y + chess_model.front_center_offset_y * OFFSET
		else:
			if (chess_model.back_center_offset_x != 0 or chess_model.back_center_offset_y != 0):
				back_center.position.x = CENTER_X + chess_model.back_center_offset_x * OFFSET
				back_center.position.y = CENTER_Y + chess_model.back_center_offset_y * OFFSET
		
		# set movements
		var movements_dict = chess_model.front_dict if is_front else chess_model.back_dict
			
		for a in movements_dict:
			if (a == ChessModel.ACTION_TYPE.MOVE or a == ChessModel.ACTION_TYPE.COMMAND):
				var movements = movements_dict[a]
				
				for dest in movements:
					var type = movements[dest]
					
					var offset_x = Global.dest_to_offsets_for_chess(dest)[0]
					var offset_y = Global.dest_to_offsets_for_chess(dest)[1]
					
					var node = Sprite2D.new()
					
					# set texture
					node.set_texture(Global.chess_loader.type_to_texture(type, offset_x, offset_y))
							
					# set node position and scale
					var center_offset_x = chess_model.front_center_offset_x if is_front else chess_model.back_center_offset_x
					var center_offset_y = chess_model.front_center_offset_y if is_front else chess_model.back_center_offset_y
					
					node.position.x = CENTER_X + (center_offset_x + offset_x) * OFFSET
					node.position.y = CENTER_Y + (center_offset_y + offset_y) * OFFSET

					node.scale = Vector2(0.55, 0.55)

					if (is_front):
						front_container.add_child(node)
					else:
						back_container.add_child(node)
	
	# set name
	front_name_label.text = chess
	back_name_label.text = chess
	name_label.text = chess
	
	# set image
	front_side_image.set_texture(ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null)
	back_side_image.set_texture(ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null)


func _on_gui_input(event):
	if (event is InputEventMouseButton):
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				chess_pressed.emit(self)
