extends ColorRect

@onready var chess_back_center = $CardBack/Center

const CENTER_X = 71
const CENTER_Y = 71
const OFFSET = 28

# Called when the node enters the scene tree for the first time.
func _ready():
	$CardBack.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collection_button_pressed():
	$BlurContainer/WrapperWindow.load_window("collection")
	$BlurContainer/WrapperWindow.get_loaded_window().ok_button_pressed.connect(func(): $BlurContainer.complete())
	$BlurContainer.activate()

# TODO: this is similar to the one in ChessInShow.gd, can we combine into one function?
func setup_chess_back(chess, is_front):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[chess]
	
	# move center if necessary
	var center_offset_x = chess_model.front_center_offset_x if is_front else chess_model.back_center_offset_x
	var center_offset_y = chess_model.front_center_offset_y if is_front else chess_model.back_center_offset_y
	
	chess_back_center.position.x = CENTER_X + center_offset_x * OFFSET
	chess_back_center.position.y = CENTER_Y + center_offset_y * OFFSET

	# set movements
	var movements_dict = chess_model.front_dict if is_front else chess_model.back_dict
		
	for a in movements_dict:
		if (a == ChessModel.ACTION_TYPE.MOVE or a == ChessModel.ACTION_TYPE.COMMAND):
			var movements = movements_dict[a]
			
			for dest in movements:
				var type = movements[dest]
				
				var offset_x = ChessModel.dest_to_offsets_for_chess(dest)[0]
				var offset_y = ChessModel.dest_to_offsets_for_chess(dest)[1]
				
				var node = Sprite2D.new()
				
				# set texture
				node.set_texture(Global.chess_loader.type_to_texture(type, offset_x, offset_y))
						
				# set node position and scale
				node.position.x = CENTER_X + (center_offset_x + offset_x) * OFFSET
				node.position.y = CENTER_Y + (center_offset_y + offset_y) * OFFSET

				node.scale = Vector2(0.55, 0.55)

				$CardBack.add_child(node)
	
	# set name
	$CardBack/Name/NameLabel.text = chess
	
	# set image
	$CardBack/SideImage.set_texture(ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null)
