class_name ChessInst

var is_front = true
var name = ""
var player:Player

# TODO: we may also consider putting board as one member variable
func _init(name, player):
	self.name = name
	self.player = player

func get_all_movements(action):
	var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[name]
	return chess_model.front_dict[action] if is_front else chess_model.back_dict[action]

func get_available_movements(board, pos, action):
	var ret = {}
	
	var all_movements = get_all_movements(action)
	for possible_d in all_movements:
		var valid_ds = Global.movement_manager.validate_movement(all_movements[possible_d], board, pos, possible_d, player)
		for valid_d in valid_ds:
			ret[valid_d] = all_movements[possible_d]
			
	return ret
