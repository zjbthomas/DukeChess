class_name ChessInst

var is_front = true
var name = ""
var player:Player

# TODO: we may also consider putting board as one member variable
func _init(name, player):
	self.name = name
	self.player = player

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
	
	var all_movements = get_all_movements(action)
	if (all_movements != null):
		for possible_d in all_movements:
			var valid_ds = Global.movement_manager.validate_movement(all_movements[possible_d], board, pos, possible_d, player)
			ret.append_array(valid_ds)
			
	return ret

func get_available_movements(board, pos, action):
	var ret = {}
	
	var all_movements = get_all_movements(action)
	if (all_movements != null):
		for possible_d in all_movements:
			var valid_ds = Global.movement_manager.validate_movement(all_movements[possible_d], board, pos, possible_d, player)
			for valid_d in valid_ds:
				ret[valid_d] = all_movements[possible_d]
			
	return ret
	
func get_control_area(board, pos):
	var ret = []
	
	for d in get_available_destinations(board, pos, ChessModel.ACTION_TYPE.MOVE):
		if (not ret.has(d)):
			ret.append(d)
			
	for d in get_available_destinations(board, pos, ChessModel.ACTION_TYPE.COMMAND):
		if (not ret.has(d)):
			ret.append(d)
	
	return ret
