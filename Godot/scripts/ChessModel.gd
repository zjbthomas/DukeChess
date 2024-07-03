class_name ChessModel

enum ACTION_TYPE {MOVE, SUMMON, COMMAND}
enum MOVEMENT_TYPE {MOVE, JUMP, SLIDE, JUMPSLIDE, COMMAND}

var name = ""
var version = 1

var front_actions = {}
var back_actions = {}

var image = null

var is_front = true
