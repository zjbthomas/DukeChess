extends Node

class_name Player

var is_main_player

var chess_amount_dict

func _init(is_main_player):
	self.is_main_player = is_main_player
	
	chess_amount_dict = Global.chess_loader.chess_max_amount_dict.duplicate(true)

func index_to_direction():
	return 1 if is_main_player else -1
	
func add_chess(chess):
	# TODO: guard when the amount is more than allowed maximum
	chess_amount_dict[chess] += 1	

func remove_chess(chess):
	# TODO: guard when the amount is no more than 1
	chess_amount_dict[chess] -= 1

func get_random_summon_chess():
	var chess_list = []
	
	for chess in chess_amount_dict:
		for i in chess_amount_dict[chess]:
			chess_list.append(chess)
			
	return chess_list.pick_random()
