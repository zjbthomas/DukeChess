extends AspectRatioContainer

@onready var front_container = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer
@onready var front_name_label = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer/Name/NameLabel
@onready var front_side_image = $VBoxContainer/ChessInfoContainer/Front/AspectRatioContainer/SideImage

@onready var back_container = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer
@onready var back_name_label = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer/Name/NameLabel
@onready var back_side_image = $VBoxContainer/ChessInfoContainer/Back/AspectRatioContainer/SideImage

@onready var name_label = $VBoxContainer/HBoxContainer/NameLabel

const CENTER_X = 71
const CENTER_Y = 71
const OFFSET = 28

var chess

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# TODO: this is similar to the one in Chess.gd, can we combine into one function?
func setup_ui():
	# set movements
	var chess_model = Global.chess_loader.chessmodel_dict[chess]
	
	for is_front in [true, false]:
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
					node.position.x = CENTER_X + offset_x * OFFSET
					node.position.y = CENTER_Y + offset_y * OFFSET

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

	# set amount value
	$VBoxContainer/HBoxContainer/SpinBox.set_value_no_signal(Global.chess_loader.chess_max_amount_dict[chess])
	
	# some special rules
	if (chess == "Duke"):
		$VBoxContainer/HBoxContainer/SpinBox.editable = false
		
	if (chess == "Footman"):
		$VBoxContainer/HBoxContainer/SpinBox.min_value = 2

# TODO: do we need to add special rules here to filter value?
func _on_spin_box_value_changed(value):
	Global.chess_loader.chess_max_amount_dict[chess] = int(value)
