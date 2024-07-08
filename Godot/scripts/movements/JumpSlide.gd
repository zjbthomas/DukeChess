extends Node

class_name JumpSlide

func validate_movement(board, pos, dest, player):
	var ret = []
		
	var offset_x = Global.dest_to_offsets_with_player(dest, player)[0]
	var offset_y = Global.dest_to_offsets_with_player(dest, player)[1]
		
	# TODO: why needed?
	if (offset_x != 0 and offset_y != 0 and abs(offset_x) != abs(offset_y)):
		return ret	

	if (abs(offset_x) == 1 or abs(offset_y) == 1):
		return ret
		
	if (not MovementManager.is_inside_board(board, pos, offset_x, offset_y) or
		MovementManager.has_friend_chess(board, pos, offset_x, offset_y, player)):
			return ret
	
	var start_pos = MovementManager.pos_with_offsets(pos, offset_x, offset_y)
	
	ret.append(start_pos)

	var step_x = MovementManager.get_step(offset_x, offset_y)[0]
	var step_y = MovementManager.get_step(offset_x, offset_y)[1]

	var temp_x = step_x
	var temp_y = step_y

	while (MovementManager.is_inside_board(board, start_pos, temp_x, temp_y)):
		if (MovementManager.has_friend_chess(board, start_pos, temp_x, temp_y, player)):
			return ret
		elif (MovementManager.has_enemy_chess(board, start_pos, temp_x, temp_y, player)):
			ret.append(MovementManager.pos_with_offsets(start_pos, temp_x, temp_y))
			return ret
		else:
			ret.append(MovementManager.pos_with_offsets(start_pos, temp_x, temp_y))
			
		temp_x += step_x
		temp_y += step_y

	return ret