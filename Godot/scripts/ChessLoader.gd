extends Node

class_name ChessLoader

signal error_message(msg)

const RESCHESSDIR = "res://chess"
const USERCHESSDIR = "user://chess"

var chess_name_list
var chess_object_list

func _init():
	pass
	
func load_chess():
	# create "chess" folder under user:// if not exists
	if not DirAccess.dir_exists_absolute(USERCHESSDIR):
		var error_code = DirAccess.make_dir_recursive_absolute(USERCHESSDIR)
		if error_code != OK:
			error_message.emit('ERROR: create directory with error code %s.' % [error_code])
			return

	# copy preset chess to user chess folder
	_copy_dir_recursively(RESCHESSDIR, USERCHESSDIR)
	
	# load chess from XMLs
	_load_chess_xmls()
	
func _load_chess_xmls():
	var chess_dir = DirAccess.open(USERCHESSDIR)
	
	for chess_name in chess_dir.get_directories():
		var xml_path = USERCHESSDIR + "/" + chess_name + "/" + chess_name + ".xml"
		if not FileAccess.file_exists(xml_path):
			error_message.emit('ERROR: %s not exists.' % [xml_path])

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
