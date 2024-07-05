class_name ChessModel

enum ACTION_TYPE {MOVE, SUMMON, COMMAND}
enum MOVEMENT_TYPE {MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON}

var name = ""
var version = 1

var front_center_offset_x = 0
var front_center_offset_y = 0
var back_center_offset_x = 0
var back_center_offset_y = 0

var front_dict = {}
var back_dict = {}

var image = null

var is_front = true

# for creating chess
static func dest_to_offsets_for_chess(d):
	var x = 0
	var y = 0
	
	for c in d:
		match c:
			'U':
				y -= 1
			'D':
				y += 1
			'L':
				x -= 1
			'R':
				x += 1
	
	return [x, y]
