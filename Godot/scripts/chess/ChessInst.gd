class_name ChessInst

var is_front = true
var name = ""
var player:Player

# TODO: we may also consider putting board as one member variable
func _init(name, player):
	self.name = name
	self.player = player

func duplicate():
	var new_chess_inst = ChessInst.new(self.name, self.player)
	new_chess_inst.is_front = self.is_front
	
	return new_chess_inst

func get_available_actions(board, pos):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[name]
	var all_actions = chess_model.front_dict.keys() if is_front else chess_model.back_dict.keys()
	
	var ret = []
	
	for a in all_actions:
		if a == ChessModel.ACTION_TYPE.SUMMON:
			if (not player.is_summon_available()):
				continue
		
		var dests = get_available_destinations(board, pos, a)
		if (len(dests) == 0):
			continue
			
		ret.append(a)
	
	return ret

func get_all_movements(action):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[name]
	return chess_model.front_dict.get(action) if is_front else chess_model.back_dict.get(action)

func get_available_destinations(board, pos, action):
	var ret = []
	
	if (action == ChessModel.ACTION_TYPE.COMMAND):
		var has_commandable_chess = false
		var all_command_movements = get_all_movements(ChessModel.ACTION_TYPE.COMMAND)
		if (all_command_movements != null):
			for possible_d in all_command_movements:
				var offset_x = Global.dest_to_offsets_with_player(possible_d, player)[0]
				var offset_y = Global.dest_to_offsets_with_player(possible_d, player)[1]
				
				if (Global.movement_manager.has_friend_chess(board, pos, offset_x, offset_y, player)):
					has_commandable_chess = true
					break
			
		if (not has_commandable_chess):
			return ret
	
	var all_movements = get_all_movements(action)
	if (all_movements != null):
		for possible_d in all_movements:
			var valid_ds = Global.movement_manager.validate_movement(all_movements[possible_d], board, pos, possible_d, player)
			ret.append_array(valid_ds)
			
	return ret

func get_available_movements(board, pos, action):
	var ret = {}
	
	if (action == ChessModel.ACTION_TYPE.COMMAND):
		var has_commandable_chess = false
		var all_command_movements = get_all_movements(ChessModel.ACTION_TYPE.COMMAND)
		if (all_command_movements != null):
			for possible_d in all_command_movements:
				var offset_x = Global.dest_to_offsets_with_player(possible_d, player)[0]
				var offset_y = Global.dest_to_offsets_with_player(possible_d, player)[1]
				
				if (Global.movement_manager.has_friend_chess(board, pos, offset_x, offset_y, player)):
					has_commandable_chess = true
					break
			
		if (not has_commandable_chess):
			return ret
	
	var all_movements = get_all_movements(action)
	if (all_movements != null):
		for possible_d in all_movements:
			var valid_ds = Global.movement_manager.validate_movement(all_movements[possible_d], board, pos, possible_d, player)
			for valid_d in valid_ds:
				ret[valid_d] = all_movements[possible_d]
			
	return ret
	
func get_control_area(board, pos):
	var ret = []
	
	var all_move_movements = get_all_movements(ChessModel.ACTION_TYPE.MOVE)
	if (all_move_movements != null):
		for possible_d in all_move_movements:
			var valid_ds = Global.movement_manager.validate_control_area(all_move_movements[possible_d], board, pos, possible_d, player)
			ret.append_array(valid_ds)
	
	var has_commandable_chess = false
	var all_command_movements = get_all_movements(ChessModel.ACTION_TYPE.COMMAND)
	if (all_command_movements != null):
		for possible_d in all_command_movements:
			var offset_x = Global.dest_to_offsets_with_player(possible_d, player)[0]
			var offset_y = Global.dest_to_offsets_with_player(possible_d, player)[1]
			
			if (Global.movement_manager.has_friend_chess(board, pos, offset_x, offset_y, player)):
				has_commandable_chess = true
				break
		
		if (has_commandable_chess):
			for possible_d in all_command_movements:
				var valid_ds = Global.movement_manager.validate_control_area(all_command_movements[possible_d], board, pos, possible_d, player)
				ret.append_array(valid_ds)
	
	return ret

func get_defended_area(board, pos):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[name]
	var auras_dict = chess_model.front_aura_dict if is_front else chess_model.back_aura_dict
	var defense_auras = auras_dict.get(Global.movement_manager.AURA_TYPE.DEFENSE)

	var ret = []
	
	if (defense_auras != null):
		for dest in defense_auras:
			var offset_x = Global.dest_to_offsets_for_chess(dest)[0]
			var offset_y = Global.dest_to_offsets_for_chess(dest)[1]
			
			if (Global.movement_manager.is_inside_board(board, pos, offset_x, offset_y)):
				ret.append(Global.movement_manager.pos_with_offsets(pos, offset_x, offset_y))
			
	return ret
