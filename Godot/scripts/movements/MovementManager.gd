extends Node

class_name MovementManager

enum MOVEMENT_TYPE {MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON}

var movement_insts = {
	MOVEMENT_TYPE.MOVE: Move.new(),
	MOVEMENT_TYPE.SLIDE: Slide.new(),
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

static func has_friend_chess(board, pos, offset_x, offset_y, player):
	return has_any_chess(board, pos, offset_x, offset_y) and \
			(board[pos_with_offsets(pos, offset_x, offset_y)].player == player)

static func has_enemy_chess(board, pos, offset_x, offset_y, player):
	return has_any_chess(board, pos, offset_x, offset_y) and \
			(not has_friend_chess(board, pos, offset_x, offset_y, player))

static func get_step(offset_x, offset_y):
	var step_x = 0
	var step_y = 0
	
	if (offset_x > 0):
		step_x = 1
	elif (offset_x < 0):
		step_x = -1
	
	if (offset_y > 0):
		step_y = 1
	elif (offset_y < 0):
		step_y = -1
	
	return [step_x, step_y]
