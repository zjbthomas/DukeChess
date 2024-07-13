extends Node

const MAXR = 6
const MAXC = 6

const WINDOW_TYPE = {
	"collection": "res://scenes//CollectionWindowGUI.tscn",
}

const LOCALES = {
	"en": "English",
	"zh": "简体中文"
}

enum AI_MODE {EASY=2, HARD=3}

var chess_loader:ChessLoader

var movement_manager:MovementManager = MovementManager.new()

var is_local = false
var is_ai = false
var ai_depth:AI_MODE

func rc_to_n(r, c):
	return r * Global.MAXC + c
	
func n_to_rc(n):
	var r:int = int(n) / Global.MAXC
	var c:int = int(n) % Global.MAXC
	
	return [r, c]

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
	
# for movement with player direction
static func dest_to_offsets_with_player(d, player:Player):
	var x = 0
	var y = 0
	
	for c in d:
		match c:
			'U':
				y -= 1 * player.index_to_direction()
			'D':
				y += 1 * player.index_to_direction()
			'L':
				x -= 1
			'R':
				x += 1
	
	return [x, y]
