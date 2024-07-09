extends ColorRect

@onready var chess_back_center = $CardBack/Center

const CENTER_X = 71
const CENTER_Y = 71
const OFFSET = 28

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_ui_localization()
	
	$CardBack.visible = false
	
	# set remaining chess area
	$AspectRatioContainer/PanelContainer/SummonInfo/Player1Label.visible = Global.is_local
	$AspectRatioContainer/PanelContainer/SummonInfo/Player2Label.visible = Global.is_local
	$AspectRatioContainer/PanelContainer/SummonInfo/Player2RemainLabel.visible = Global.is_local

func _setup_ui_localization():
	# $GridContainer/Label is set in Main.gd
	
	$GridContainer/BackButton.text = tr("MAIN_BUTTON_BACK")
	$GridContainer/StartButton.text = tr("MAIN_BUTTON_START")
	$GridContainer/CollectionButton.text = tr("MAIN_BUTTON_CHESS")
	$GridContainer/ExitButton.text = tr("MAIN_BUTTON_EXIT")
	
	$MessageContainer/Panel/MessageLabel.text = tr("MAIN_MSG_DEFAULT")
	
	$AspectRatioContainer/PanelContainer/SummonInfo/Label.text = tr("MAIN_RAMINING_CHESS")
	$AspectRatioContainer/PanelContainer/SummonInfo/Player1Label.text = tr("MAIN_PLAYER1")
	$AspectRatioContainer/PanelContainer/SummonInfo/Player2Label.text = tr("MAIN_PLAYER2")
	
	$ControlAreaControls/Player1ControlArea.text = tr("MAIN_SHOW_PLAYER1_CONTROL_AREA")
	$ControlAreaControls/Player2ControlArea.text = tr("MAIN_SHOW_PLAYER2_CONTROL_AREA")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_collection_button_pressed():
	$BlurContainer/WrapperWindow.load_window("collection")
	$BlurContainer/WrapperWindow.get_loaded_window().ok_button_pressed.connect(func(): $BlurContainer.complete())
	$BlurContainer.activate()

# TODO: this is similar to the one in ChessInShow.gd, can we combine into one function?
func setup_chess_back(chess, is_front):
	# remove all previous nodes in group "movements"
	get_tree().call_group("movements", "queue_free")
	
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
				
				var offset_x = Global.dest_to_offsets_for_chess(dest)[0]
				var offset_y = Global.dest_to_offsets_for_chess(dest)[1]
				
				var node = Sprite2D.new()
				
				# set texture
				node.set_texture(Global.chess_loader.type_to_texture(type, offset_x, offset_y))
						
				# set node position and scale
				node.position.x = CENTER_X + (center_offset_x + offset_x) * OFFSET
				node.position.y = CENTER_Y + (center_offset_y + offset_y) * OFFSET

				node.scale = Vector2(0.55, 0.55)

				node.add_to_group("movements")

				$CardBack.add_child(node)
					
	# set name
	$CardBack/Name/NameLabel.text = chess
	
	# set image
	$CardBack/SideImage.set_texture(ImageTexture.create_from_image(Image.load_from_file(chess_model.image)) if chess_model.image != null else null)


func _on_exit_button_pressed():
	get_tree().quit()
