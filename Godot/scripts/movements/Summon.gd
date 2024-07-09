extends Node

class_name Summon

func validate_movement(board, pos, dest, player):
	var ret = []
	
	var offset_x = Global.dest_to_offsets_with_player(dest, player)[0]
	var offset_y = Global.dest_to_offsets_with_player(dest, player)[1]

	# TODO: why needed?
	if (offset_x != 0 and offset_y != 0 and abs(offset_x) != abs(offset_y)):
		return ret
		
	if not (abs(offset_x) == 1 or abs(offset_y) == 1):
		return ret
	
	if (not MovementManager.is_inside_board(board, pos, offset_x, offset_y) or 
		MovementManager.has_any_chess(board, pos, offset_x, offset_y)):
		return ret

	ret.append(MovementManager.pos_with_offsets(pos, offset_x, offset_y))
	
	return ret

func validate_control_area(board, pos, dest, player):
	return []
