extends Node

class_name MovementManager

enum MOVEMENT_TYPE {MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON}

var movement_insts = {
	MOVEMENT_TYPE.SUMMON: Summon.new()
}

func validate_movement(type, board, pos, dest, player):
	return movement_insts[type].validate_movement(board, pos, dest, player)

static func pos_with_offsets(pos, offset_x, offset_y):
	return pos + offset_y * Global.MAXC + offset_x

static func is_inside_board(board, pos, offset_x, offset_y):
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	
	return (c + offset_x >= 0) and (c + offset_x < Global.MAXC) and \
			(r + offset_y >= 0) and (r + offset_y < Global.MAXR)
			
static func has_any_chess(board, pos, offset_x, offset_y):
	return board[pos_with_offsets(pos, offset_x, offset_y)] != null
