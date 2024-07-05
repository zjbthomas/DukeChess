extends StaticBody3D

@onready var front_center = $Front/Center
@onready var back_center = $Back/Center

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
	
	var chess_model = Global.chess_loader.chessmodel_dict[chess.name]
	
	for is_front in [true, false]:
		# move center if necessary
		if (is_front):
			if (chess_model.front_center_offset_x != 0 or chess_model.front_center_offset_y != 0):
				front_center.position.x = CENTER_X - chess_model.front_center_offset_x * OFFSET
				front_center.position.y = CENTER_Y + chess_model.front_center_offset_y * OFFSET
		else:
			if (chess_model.back_center_offset_x != 0 or chess_model.back_center_offset_y != 0):
				back_center.position.x = CENTER_X - chess_model.back_center_offset_x * OFFSET
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
					
					var node = Sprite3D.new()
					
					# set texture
					node.set_texture(Global.chess_loader.type_to_texture(type, offset_x, offset_y))
							
					# set node position
					var center_offset_x = chess_model.front_center_offset_x if is_front else chess_model.back_center_offset_x
					var center_offset_y = chess_model.front_center_offset_y if is_front else chess_model.back_center_offset_y
					
					node.position.x = CENTER_X - (center_offset_x + offset_x) * OFFSET
					node.position.y = CENTER_Y + (center_offset_y + offset_y) * OFFSET

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
