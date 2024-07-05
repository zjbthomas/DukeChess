class_name ChessLoader

signal error_message(msg)

const RESCHESSDIR = "res://chess"
const USERCHESSDIR = "user://chess"
const CHESSAMOUNTJSON = "chess_amount.json"

var chess_name_list = []
var chess_max_amount_dict = {}
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

func type_to_texture(type, offset_x, offset_y):
	match type:
		MovementManager.MOVEMENT_TYPE.MOVE:
			return chess_textures["Move"]
			
		MovementManager.MOVEMENT_TYPE.JUMP:
			return chess_textures["Jump"]
			
		MovementManager.MOVEMENT_TYPE.SLIDE:
			if (offset_x == -1 and offset_y == -1):
				return chess_textures["SlideUL"]
			elif (offset_x == 0 and offset_y == -1):
				return chess_textures["SlideU"]
			elif (offset_x == 1 and offset_y == -1):
				return chess_textures["SlideUR"]
			elif (offset_x == -1 and offset_y == 0):
				return chess_textures["SlideL"]
			elif (offset_x == 1 and offset_y == 0):
				return chess_textures["SlideR"]
			elif (offset_x == -1 and offset_y == 1):
				return chess_textures["SlideDL"]
			elif (offset_x == 0 and offset_y == 1):
				return chess_textures["SlideD"]
			elif (offset_x == 1 and offset_y == 1):
				return chess_textures["SlideDR"]
				
		MovementManager.MOVEMENT_TYPE.JUMPSLIDE:
			if (offset_x == -2 and offset_y == -2):
				return chess_textures["JumpSlideUULL"]
			elif (offset_x == 0 and offset_y == -2):
				return chess_textures["JumpSlideUU"]
			elif (offset_x == 2 and offset_y == -2):
				return chess_textures["JumpSlideUURR"]
			elif (offset_x == -2 and offset_y == 0):
				return chess_textures["JumpSlideLL"]
			elif (offset_x == 2 and offset_y == 0):
				return chess_textures["JumpSlideRR"]
			elif (offset_x == -2 and offset_y == 2):
				return chess_textures["JumpSlideDDLL"]
			elif (offset_x == 0 and offset_y == 2):
				return chess_textures["JumpSlideDD"]
			elif (offset_x == 2 and offset_y == 2):
				return chess_textures["JumpSlideDDRR"]
		
		MovementManager.MOVEMENT_TYPE.STRIKE:
			return chess_textures["Strike"]
			
		MovementManager.MOVEMENT_TYPE.COMMAND:
				return chess_textures["Command"]

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
		
		# center offsets
		if (xml_root.front.get('center') != null):
			var front_center_offset_x = Global.dest_to_offsets_for_chess(xml_root.front.center.content)[0]
			var front_center_offset_y = Global.dest_to_offsets_for_chess(xml_root.front.center.content)[1]
			
			chess.front_center_offset_x = front_center_offset_x
			chess.front_center_offset_y = front_center_offset_y
			
		if (xml_root.back.get('center') != null):
			var back_center_offset_x = Global.dest_to_offsets_for_chess(xml_root.back.center.content)[0]
			var back_center_offset_y = Global.dest_to_offsets_for_chess(xml_root.back.center.content)[1]
			
			chess.back_center_offset_x = back_center_offset_x
			chess.back_center_offset_y = back_center_offset_y
		
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
		
	# set default chess num from JSON
	var json_as_text = FileAccess.get_file_as_string(USERCHESSDIR + "/" + CHESSAMOUNTJSON)
	var json_as_dict = JSON.parse_string(json_as_text)
	if not json_as_dict:
		error_message.emit('ERROR: cannot parse JSON %s.' % [USERCHESSDIR + "/" + CHESSAMOUNTJSON])
		return
			
	for chess_name in chess_name_list:
		var amount_str = json_as_dict.get(chess_name)
		
		if not amount_str:
			error_message.emit('ERROR: amount for %s cannot be load from %s.' % [chess_name, USERCHESSDIR + "/" + CHESSAMOUNTJSON])
			return
		
		var amount = int(amount_str)
		
		# some special rules
		if (chess_name == "Duke"):
			if (amount != 1):
				error_message.emit('ERROR: incorrect amount %s for Duke in %s.' % [amount, USERCHESSDIR + "/" + CHESSAMOUNTJSON])
				return
				
		if (chess_name == "Footman"):
			if (amount < 2):
				error_message.emit('ERROR: there should at least 2 (now only %s) Footman in %s.' % [amount, USERCHESSDIR + "/" + CHESSAMOUNTJSON])
				return
		
		chess_max_amount_dict[chess_name] = amount
	
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
		
		targets[destination] = MovementManager.MOVEMENT_TYPE[type.to_upper()]
		
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
		if (filename == CHESSAMOUNTJSON):
			# copy only when not exists
			if not FileAccess.file_exists(destination + "/" + filename):
				source_dir.copy(source + "/" + filename, destination + "/" + filename)
		
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
	for vt in MovementManager.MOVEMENT_TYPE.keys():
		if (t.to_upper() == str(vt)):
			return true

	var offset_x = Global.dest_to_offsets_for_chess(d)[0]
	var offset_y = Global.dest_to_offsets_for_chess(d)[1]

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
