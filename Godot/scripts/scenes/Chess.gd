extends StaticBody3D

const CENTER_X = -0.54
const CENTER_Y = 0.55
const OFFSET = -0.54

var chess:ChessInst

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_ui():
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
					match type:
						ChessModel.MOVEMENT_TYPE.MOVE:
							node.set_texture(Global.chess_loader.chess_textures["Move"])
							
						ChessModel.MOVEMENT_TYPE.JUMP:
							node.set_texture(Global.chess_loader.chess_textures["Jump"])
							
						ChessModel.MOVEMENT_TYPE.SLIDE:
							if (offset_x == -1 and offset_y == -1):
								node.set_texture(Global.chess_loader.chess_textures["SlideUL"])
							elif (offset_x == 0 and offset_y == -1):
								node.set_texture(Global.chess_loader.chess_textures["SlideU"])
							elif (offset_x == -1 and offset_y == 1):
								node.set_texture(Global.chess_loader.chess_textures["SlideUR"])
							elif (offset_x == -1 and offset_y == 0):
								node.set_texture(Global.chess_loader.chess_textures["SlideL"])
							elif (offset_x == 1 and offset_y == 0):
								node.set_texture(Global.chess_loader.chess_textures["SlideR"])
							elif (offset_x == -1 and offset_y == 1):
								node.set_texture(Global.chess_loader.chess_textures["SlideDL"])
							elif (offset_x == 0 and offset_y == 1):
								node.set_texture(Global.chess_loader.chess_textures["SlideD"])
							elif (offset_x == 1 and offset_y == 1):
								node.set_texture(Global.chess_loader.chess_textures["SlideDR"])
								
						ChessModel.MOVEMENT_TYPE.JUMPSLIDE:
							if (offset_x == -2 and offset_y == -2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideUULL"])
							elif (offset_x == 0 and offset_y == -2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideUU"])
							elif (offset_x == 2 and offset_y == -2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideUURR"])
							elif (offset_x == -2 and offset_y == 0):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideLL"])
							elif (offset_x == 2 and offset_y == 0):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideRR"])
							elif (offset_x == -2 and offset_y == 2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideDDLL"])
							elif (offset_x == 0 and offset_y == 2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideDD"])
							elif (offset_x == 2 and offset_y == 2):
								node.set_texture(Global.chess_loader.chess_textures["JumpSlideDDRR"])
						
						ChessModel.MOVEMENT_TYPE.STRIKE:
							node.set_texture(Global.chess_loader.chess_textures["Strike"])
							
						ChessModel.MOVEMENT_TYPE.COMMAND:
								node.set_texture(Global.chess_loader.chess_textures["Command"])
							
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
		
