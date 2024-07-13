extends Node

class_name MovementManager

enum MOVEMENT_TYPE {MOVE, JUMP, SLIDE, JUMPSLIDE, STRIKE, COMMAND, SUMMON}
enum AURA_TYPE {DEFENSE}

var movement_insts = {
	MOVEMENT_TYPE.MOVE: Move.new(),
	MOVEMENT_TYPE.JUMP: Jump.new(),
	MOVEMENT_TYPE.SLIDE: Slide.new(),
	MOVEMENT_TYPE.JUMPSLIDE: JumpSlide.new(),
	MOVEMENT_TYPE.STRIKE: Strike.new(),
	MOVEMENT_TYPE.COMMAND: Command.new(),
	MOVEMENT_TYPE.SUMMON: Summon.new()
}

func validate_movement(type, board, pos, dest, player):
	return movement_insts[type].validate_movement(board, pos, dest, player)

func validate_control_area(type, board, pos, dest, player):
	return movement_insts[type].validate_control_area(board, pos, dest, player)

static func pos_with_offsets(pos, offset_x, offset_y):
	return pos + offset_y * Global.MAXC + offset_x

static func is_inside_board(board, pos, offset_x, offset_y):
	var r = Global.n_to_rc(pos)[0]
	var c = Global.n_to_rc(pos)[1]
	
	return (c + offset_x >= 0) and (c + offset_x < Global.MAXC) and \
			(r + offset_y >= 0) and (r + offset_y < Global.MAXR)
			
static func has_any_chess(board, pos, offset_x, offset_y):
	return is_inside_board(board, pos, offset_x, offset_y) and \
			board[pos_with_offsets(pos, offset_x, offset_y)] != null

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

static func has_defended_enemy(board, pos, offset_x, offset_y, player):
	# if destination is an enemy chess, check if there is a possible path without defense
	if (MovementManager.has_enemy_chess(board, pos, offset_x, offset_y, player)):
		# check original position
		if MovementManager.is_defended_by_enemy(board, pos, 0, 0, player):
			return true

		var has_valid_path = false
		for pp in MovementManager.find_possible_paths(offset_x, offset_y):
			var is_path_valid = true
			for point in pp:
				var px = point[0]
				var py = point[1]
				
				# final destination would not be defended
				if (px == offset_x and py == offset_y):
					continue
					
				if MovementManager.is_defended_by_enemy(board, pos, px, py, player):
					is_path_valid = false
					
			if (is_path_valid):
				has_valid_path = true
				break
		
		if (not has_valid_path):
			return true
			
	return false

static func is_defended_by_enemy(board, pos, offset_x, offset_y, player):
	for n in range(Global.MAXR * Global.MAXC):
		if board[n] != null and board[n].player != player:
			if (board[n].get_defended_area(board, n).has(pos_with_offsets(pos, offset_x, offset_y))):
				return true
				
	return false

static func find_possible_paths(offset_x, offset_y):
	var d_x = 0 if offset_x == 0 else (1 if offset_x > 0 else -1)
	var d_y = 0 if offset_y == 0 else (1 if offset_y > 0 else -1)
	
	var possible_paths = []
	
	# straight line
	if (abs(offset_x) == abs(offset_y) or abs(offset_x) == 0 or abs(offset_y) == 0):
		var temp_x = 0
		var temp_y = 0
		
		var path = []
		
		while (abs(temp_x) < abs(offset_x) or abs(temp_y) < abs(offset_y)):
			temp_x += d_x
			temp_y += d_y

			path.append([temp_x, temp_y])
			
		possible_paths.append(path)
	else:
		find_possible_paths_step(0, 0, d_x, d_y, offset_x, offset_y, [], possible_paths)
	
	return possible_paths

static func find_possible_paths_step(cur_x, cur_y, d_x, d_y, final_x, final_y, prev_path, possible_paths):
	if (cur_x == final_x and cur_y == final_y):
		possible_paths.append(prev_path)
		return
	
	var new_cur_x = cur_x + d_x
	var new_cur_y = cur_y + d_y
	
	if (abs(new_cur_x) <= abs(final_x)):
		var new_prev_path = prev_path.duplicate()
		new_prev_path.append([new_cur_x, cur_y])

		find_possible_paths_step(new_cur_x, cur_y, d_x, d_y, final_x, final_y, new_prev_path, possible_paths)

	if (abs(new_cur_y) <= abs(final_y)):
		var new_prev_path = prev_path.duplicate()
		new_prev_path.append([cur_x, new_cur_y])

		find_possible_paths_step(cur_x, new_cur_y, d_x, d_y, final_x, final_y, new_prev_path, possible_paths)
