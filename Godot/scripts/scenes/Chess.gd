extends StaticBody3D

const CENTER_X = -0.54
const CENTER_Y = 0.55
const OFFSET = -0.54

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_ui(chess):
	# set movements
	var chess_model = Global.chess_loader.chessmodel_dict[chess.name]
	
	for is_front in [true, false]:
		var movements_dict = chess_model.front_dict if is_front else chess_model.back_dict
		
		for a in movements_dict:
			if (a == ChessModel.ACTION_TYPE.MOVE or a == ChessModel.ACTION_TYPE.COMMAND):
				var movements = movements_dict[a]
				
				for dest in movements:
					var type = movements[dest]
					
					var offset_x = ChessModel.dest_to_offsets_for_chess(dest)[0]
					var offset_y = ChessModel.dest_to_offsets_for_chess(dest)[1]
					
					var node = Sprite3D.new()
					
					# set texture
					node.set_texture(Global.chess_loader.type_to_texture(type, offset_x, offset_y))
							
					# set node position
					node.position.x = CENTER_X - offset_x * OFFSET
					node.position.y = CENTER_Y + offset_y * OFFSET

					if (is_front):
						$Front.add_child(node)
					else:
						$Back.add_child(node)
	
	# set name
	$Front/Name.text = chess.name
	$Back/Name.text = chess.name
	
	# set image
	$Front/SideImage.get_mesh().get_material().albedo_texture = ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null
	$Back/SideImage.get_mesh().get_material().albedo_texture = ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null
