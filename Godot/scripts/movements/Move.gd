extends Node

class_name Move

func validate_movement(board, pos, dest, player):
	var ret = []
	
	var offset_x = Global.dest_to_offsets_with_player(dest, player)[0]
	var offset_y = Global.dest_to_offsets_with_player(dest, player)[1]

	# TODO: why needed?
	if (offset_x != 0 and offset_y != 0 and abs(offset_x) != abs(offset_y)):
		return ret
	
	if (not MovementManager.is_inside_board(board, pos, offset_x, offset_y) or 
		MovementManager.has_friend_chess(board, pos, offset_x, offset_y, player)):
		return ret
		
	var half_offset_x = int(offset_x / 2) # DO NOT USE // HERE!
	var half_offset_y = int(offset_y / 2)
	
	if (half_offset_x != 0 or half_offset_y != 0):
		if (not MovementManager.is_inside_board(board, pos, half_offset_x, half_offset_y) or 
			MovementManager.has_any_chess(board, pos, half_offset_x, half_offset_y)):
				return ret

	if MovementManager.has_defended_enemy(board, pos, offset_x, offset_y, player):
		return ret

	ret.append(MovementManager.pos_with_offsets(pos, offset_x, offset_y))
	
	return ret

func validate_control_area(board, pos, dest, player):
	var ret = []
	
	var offset_x = Global.dest_to_offsets_with_player(dest, player)[0]
	var offset_y = Global.dest_to_offsets_with_player(dest, player)[1]

	# TODO: why needed?
	if (offset_x != 0 and offset_y != 0 and abs(offset_x) != abs(offset_y)):
		return ret
	
	if (not MovementManager.is_inside_board(board, pos, offset_x, offset_y)):
		return ret
	
	if (MovementManager.has_friend_chess(board, pos, offset_x, offset_y, player)):
		ret.append(MovementManager.pos_with_offsets(pos, offset_x, offset_y)) # different at here!!
		return ret
		
	var half_offset_x = int(offset_x / 2) # DO NOT USE // HERE!
	var half_offset_y = int(offset_y / 2)
	
	if (half_offset_x != 0 or half_offset_y != 0):
		if (not MovementManager.is_inside_board(board, pos, half_offset_x, half_offset_y) or 
			MovementManager.has_any_chess(board, pos, half_offset_x, half_offset_y)):
				return ret

	if MovementManager.has_defended_enemy(board, pos, offset_x, offset_y, player):
		return ret

	ret.append(MovementManager.pos_with_offsets(pos, offset_x, offset_y))
	
	return ret
