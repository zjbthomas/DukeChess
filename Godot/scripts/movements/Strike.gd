extends Node

class_name Strike

func validate_movement(board, pos, dest, player):
	var ret = []
	
	var offset_x = Global.dest_to_offsets_with_player(dest, player)[0]
	var offset_y = Global.dest_to_offsets_with_player(dest, player)[1]

	if (not MovementManager.is_inside_board(board, pos, offset_x, offset_y) or 
		MovementManager.has_friend_chess(board, pos, offset_x, offset_y, player) or
		not MovementManager.has_any_chess(board, pos, offset_x, offset_y)):
		return ret

	ret.append(MovementManager.pos_with_offsets(pos, offset_x, offset_y))
	
	return ret
