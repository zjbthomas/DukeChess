class_name ChessLoader

signal error_message(msg)

const RESCHESSDIR = "res://chess"
const USERCHESSDIR = "user://chess"

var chess_name_list = []
var chessmodel_dict = {}

var chess_textures = {}

func load_chess():
	# create "chess" folder under user:// if not exists
	if not DirAccess.dir_exists_absolute(USERCHESSDIR):
		var error_code = DirAccess.make_dir_recursive_absolute(USERCHESSDIR)
		if error_code != OK:
			error_message.emit('ERROR: create directory with error code %s.' % [error_code])
			return

	# copy preset chess to user chess folder
	_copy_dir_recursively(RESCHESSDIR, USERCHESSDIR)
	
	# load chess from files
	_load_chess_files()
	
func load_chess_textures():
	chess_textures["Move"] = load("res://images//chess//movements//Move.png")
	chess_textures["Jump"] = load("res://images//chess//movements//Jump.png")
	
	chess_textures["SlideUL"] = load("res://images//chess//movements//Slide_11.png")
	chess_textures["SlideU"] = load("res://images//chess//movements//Slide_12.png")
	chess_textures["SlideUR"] = load("res://images//chess//movements//Slide_13.png")
	chess_textures["SlideL"] = load("res://images//chess//movements//Slide_21.png")
	chess_textures["SlideR"] = load("res://images//chess//movements//Slide_23.png")
	chess_textures["SlideDL"] = load("res://images//chess//movements//Slide_31.png")
	chess_textures["SlideD"] = load("res://images//chess//movements//Slide_32.png")
	chess_textures["SlideDR"] = load("res://images//chess//movements//Slide_33.png")
	
	chess_textures["JumpSlideUULL"] = load("res://images//chess//movements//JumpSlide_00.png")
	chess_textures["JumpSlideUU"] = load("res://images//chess//movements//JumpSlide_02.png")
	chess_textures["JumpSlideUURR"] = load("res://images//chess//movements//JumpSlide_04.png")
	chess_textures["JumpSlideLL"] = load("res://images//chess//movements//JumpSlide_20.png")
	chess_textures["JumpSlideRR"] = load("res://images//chess//movements//JumpSlide_24.png")
	chess_textures["JumpSlideDDLL"] = load("res://images//chess//movements//JumpSlide_40.png")
	chess_textures["JumpSlideDD"] = load("res://images//chess//movements//JumpSlide_42.png")
	chess_textures["JumpSlideDDRR"] = load("res://images//chess//movements//JumpSlide_44.png")
	
	chess_textures["Strike"] = load("res://images//chess//movements//Strike.png")
	
	chess_textures["Command"] = load("res://images//chess//movements//Command.png")
	
func _load_chess_files():
	var chess_dir = DirAccess.open(USERCHESSDIR)
	
	for chess_name in chess_dir.get_directories():
		# load XML
		var xml_path = USERCHESSDIR + "/" + chess_name + "/" + chess_name + ".xml" # XML has the same name as the folder
		if not FileAccess.file_exists(xml_path):
			error_message.emit('ERROR: %s not exists.' % [xml_path])
			return
				
		var xml_root = XML.parse_file(xml_path).root
		
		# check name and version
		var name = xml_root.attributes["name"]
		if (name != chess_name):
			error_message.emit('ERROR: dismatch name in XML %s.' % [xml_path])
			return
			
		# TODO: length of name should not be too long
		if (name.length() > 10):
			error_message.emit('ERROR: name %s too long.' % [name])
			return
		
		var version = int(xml_root.attributes["version"])
		
		var chess = ChessModel.new()
		
		chess.name = name
		chess.version = version
		
		# front actions and movements
		for xml_movement in xml_root.front.movements.children:
			var ret = _parse_xml_root(xml_path, xml_movement)
			if (ret == null):
				return
		
			chess.front_dict[ret[0]] = ret[1]
			
		# back actions and movements
		for xml_movement in xml_root.back.movements.children:
			var ret = _parse_xml_root(xml_path, xml_movement)
			if (ret == null):
				return
		
			chess.back_dict[ret[0]] = ret[1]
			
		# load image
		var image_path = USERCHESSDIR + "/" + chess_name + "/" + chess_name + ".png" # TODO: only PNG is allowed; it has the same name as the folder
		if FileAccess.file_exists(image_path):
			chess.image = image_path
		else:
			chess.image = null # is OK to not have image

		# add chess to list
		chess_name_list.append(chess_name)
		chessmodel_dict[chess_name] = chess
	
func _parse_xml_root(xml_path, xml_movement):
	# parse targets
	var targets = {}
	for xml_target in xml_movement.targets.children:
		var destination = xml_target.destination.content
		var type = xml_target.type.content
		
		# validate
		if (not validate_type(type, destination) or not validate_destination(destination)):
			error_message.emit('ERROR: invald type %s or destination %s in XML %s.' % [type, destination, xml_path])
			return null
		
		targets[destination] = ChessModel.MOVEMENT_TYPE[type.to_upper()]
		
	var action = xml_movement.action.content
	if (not validate_action(action)):
		error_message.emit('ERROR: invald action %s in XML %s.' % [action, xml_path])
		return null
	
	return [ChessModel.ACTION_TYPE[action.to_upper()], targets]
	
# https://www.reddit.com/r/godot/comments/19f0mf2/is_there_a_way_to_copy_folders_from_res_to_user/
# REMEMBER to export preset when exporting the project!!
func _copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source)
	
	for filename in source_dir.get_files():
		if (filename.ends_with(".png") or filename.ends_with(".xml")): # TODO: only PNG and XML are supported now
			source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		_copy_dir_recursively(source + "/" + dir + "/", destination + "/" + dir + "/")

func validate_action(a):
	for va in ChessModel.ACTION_TYPE.keys():
		if (a.to_upper() == str(va)):
			return true

	return false

func validate_type(t, d):
	for vt in ChessModel.MOVEMENT_TYPE.keys():
		if (t.to_upper() == str(vt)):
			return true

	var offset_x = ChessModel.dest_to_offsets_for_chess(d)[0]
	var offset_y = ChessModel.dest_to_offsets_for_chess(d)[1]

	# check for Jump
	if (t.to_upper() == "JUMP"):
		if (abs(offset_x) >= 2 or abs(offset_y >= 2)):
			return false
			
	# check for Slide
	if (t.to_upper() == "SLIDE"):
		if (abs(offset_x) >= 2 or abs(offset_y >= 2)):
			return false
			
	# check for JumpSlide
	if (t.to_upper() == "JUMPSLIDE"):
		if (abs(offset_x) <= 1 or abs(offset_y <= 1)):
			return false
		elif ((abs(offset_x) + abs(offset_y)) % 2 != 0):
			return false

	return false

func validate_destination(d):
	if (d.length() < 1 or d.length() > 4):
		return false
		
	for c in d:
		if (c not in ['U', 'D', 'L', 'R']):
			return false
			
	return true
