class_name ChessModel

enum ACTION_TYPE {MOVE, SUMMON, COMMAND}

var name = "" # as an identifier
var version = 1

var front_center_offset_x = 0
var front_center_offset_y = 0
var back_center_offset_x = 0
var back_center_offset_y = 0

var front_dict = {}
var back_dict = {}

var front_aura_dict = {}
var back_aura_dict = {}

var image

var is_front = true

var tr_name_dict = {} # for display purpose
func get_tr_name():
	return tr_name_dict[TranslationServer.get_locale()]
