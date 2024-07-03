class_name ChessLoader

signal error_message(msg)

const RESCHESSDIR = "res://chess"
const USERCHESSDIR = "user://chess"

var chess_name_list
var chessmodel_dict

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
	
func _load_chess_files():
	chess_name_list = []
	chess_object_dict = {}
	
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
		
		var version = int(xml_root.attributes["version"])
		
		var chess = ChessModel.new()
		
		chess.name = name
		chess.version = version
		
		# front actions and movements
		for xml_movement in xml_root.front.movements.children:
			var ret = _parse_xml_root(xml_path, xml_movement)
			if (ret == null):
				return
		
			chess.front_actions[ret[0]] = ret[1]
			
		# back actions and movements
		for xml_movement in xml_root.back.movements.children:
			var ret = _parse_xml_root(xml_path, xml_movement)
			if (ret == null):
				return
		
			chess.back_actions[ret[0]] = ret[1]
			
		# load image
		var image_path = USERCHESSDIR + "/" + chess_name + "/" + chess_name + ".jpg" # TODO: only JPG is allowed; JPG has the same name as the folder
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
		if (not validate_type(type) or not validate_destination(destination)):
			error_message.emit('ERROR: invald type %s or destination %s in XML %s.' % [type, destination, xml_path])
			return null
		
		targets[destination] = type
		
	var action = xml_movement.action.content
	if (not validate_action(action)):
		error_message.emit('ERROR: invald action %s in XML %s.' % [action, xml_path])
		return null
	
	return [action, targets]
	
# https://www.reddit.com/r/godot/comments/19f0mf2/is_there_a_way_to_copy_folders_from_res_to_user/
# REMEMBER to export preset when exporting the project!!
func _copy_dir_recursively(source: String, destination: String):
	DirAccess.make_dir_recursive_absolute(destination)
	
	var source_dir = DirAccess.open(source)
	
	for filename in source_dir.get_files():
		if (filename.ends_with(".jpg") or filename.ends_with(".xml")): # TODO: only JPG and XML are supported now
			source_dir.copy(source + filename, destination + filename)
		
	for dir in source_dir.get_directories():
		_copy_dir_recursively(source + "/" + dir + "/", destination + "/" + dir + "/")

func validate_action(a):
	for va in ChessModel.ACTION_TYPE.keys():
		if (a.to_upper() == str(va)):
			return true

	return false

func validate_type(t):
	for vt in ChessModel.MOVEMENT_TYPE.keys():
		if (t.to_upper() == str(vt)):
			return true

	return false

func validate_destination(d):
	if (d.length() < 1 or d.length() > 4):
		return false
		
	for c in d:
		if (c not in ['U', 'D', 'L', 'R']):
			return false
			
	return true
