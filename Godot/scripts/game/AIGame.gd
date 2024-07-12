extends LocalGame

class_name AIGame

signal close_menu

const HISTORY_SAVED_DIR = "user://history"

var GUI

var history

func _init(GUI):
	self.GUI = GUI

func game_start():
	super()
	
	history = []
	
	# if AI is the first player, summon initial Footmans
	if (current_player != player_list[0]):
		ai_act()
		
func perform_op(user_op, is_from_menu):
	if (current_player == null or current_player != player_list[0]):
		return false
	
	# cache states before performaing action
	var cached_state = current_state
	var cached_board = board
	
	if (super(user_op, is_from_menu)):
		store_to_history(0, cached_state, cached_board, user_op, 1.0) # p is set to 1.0 if it is performed by real human

		# AI's turn
		if (current_player != player_list[0]):
			ai_act()
			
		return true
	else:
		return false

func ai_act():
	var wait_time = 0.2 + 2 * GUI._CHESS_UP_DOWN_TIME + GUI._CHESS_MOVE_TIME + GUI._CHESS_FLIP_TIME
	await GUI.get_tree().create_timer(wait_time).timeout # TODO: wait for some seconds for playing animation; it is better to be in GUI
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			var possible_destinations = board[POS_DUKE1].get_available_destinations(board, POS_DUKE1, ChessModel.ACTION_TYPE.SUMMON)
				
			var random_op_ix = randi() % len(possible_destinations)
			var random_op = possible_destinations[random_op_ix]
			
			# write to history before perform_op
			store_to_history(1, current_state, board, random_op, 1.0 / len(possible_destinations))
			
			# perform op
			super.perform_op(random_op, false)
			
			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()
		
		GAMESTATE.CHOOSECHESS:
			# find available chess
			var possible_n = []
			for n in range(Global.MAXR * Global.MAXC):
				if (board[n] != null):
					if (board[n].player == current_player):
						if len(board[n].get_available_actions(board, n)) > 0:
							possible_n.append(n)
							
			var random_op_ix = randi() % len(possible_n)
			var random_op = possible_n[random_op_ix]
			
			# write to history before perform_op
			store_to_history(1, current_state, board, random_op, 1.0 / len(possible_n))
			
			# perform op
			super.perform_op(random_op, false)
			
			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()
				
		GAMESTATE.CHOOSEACTION:
			# send a signal to close menu
			close_menu.emit()
			
			var possible_actions = board[current_chess_pos].get_available_actions(board, current_chess_pos)
		
			var random_action_ix = randi() % len(possible_actions)
			var random_action = possible_actions[random_action_ix]

			var converted_op
			match random_action:
				ChessModel.ACTION_TYPE.SUMMON:
					converted_op = "MAIN_MENU_SUMMON"
				ChessModel.ACTION_TYPE.MOVE:
					converted_op = "MAIN_MENU_MOVE"
				ChessModel.ACTION_TYPE.COMMAND:
					converted_op = "MAIN_MENU_COMMAND"
				
			store_to_history(1, current_state, board, converted_op, 1.0 / len(possible_actions))
				
			# perform op
			super.perform_op(converted_op, true)
			
			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()
				
		GAMESTATE.CHOOSEDESTONE:
			var possible_destinations = []
			match current_action:
				ChessModel.ACTION_TYPE.SUMMON:
					possible_destinations = board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.SUMMON).keys()
						
				ChessModel.ACTION_TYPE.MOVE:
					var movements = board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.MOVE)
					for d in movements:
						# Special rule for Duke
						if board[current_chess_pos].name == "Duke":
							if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d) and \
								not has_enemy_duke(d, current_player)):
								continue
						
						possible_destinations.append(d)

				ChessModel.ACTION_TYPE.COMMAND:
					for d in board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND):
						if (board[d] != null and board[d].player == current_player):
							possible_destinations.append(d)
			
			var random_op_ix = randi() % len(possible_destinations)
			var random_op = possible_destinations[random_op_ix]
			
			store_to_history(1, current_state, board, random_op, 1.0 / len(possible_destinations))

			# perform op
			super.perform_op(random_op, false)

			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()

		GAMESTATE.CHOOSEDESTTWO:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					# send a signal to close menu
					close_menu.emit()
			
					# AI will always confirm SUMMON
					var op = "MAIN_MENU_CONFIRM"
					
					store_to_history(1, current_state, board, op, 1.0)

					# perform op
					super.perform_op(op, true)
				
					# still in AI's turn
					if (current_player != player_list[0]):
						ai_act()
			
				ChessModel.ACTION_TYPE.COMMAND:
					var possible_destinations = []
					
					for d in board[current_chess_pos].get_available_destinations(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND):
						if (d != command_pos and
							((board[d] != null and board[d].player != current_player) or board[d] == null)):
								# Special rule for Duke (TODO: the server side logic should also have this)
								if board[command_pos].name == "Duke":
									if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d) and \
										not has_enemy_duke(d, current_player)):
										continue
								
								possible_destinations.append(d)
					
					var random_op_ix = randi() % len(possible_destinations)
					var random_op = possible_destinations[random_op_ix]
					
					store_to_history(1, current_state, board, random_op, 1.0 / len(possible_destinations))

					# perform op
					super.perform_op(random_op, false)
					
					# still in AI's turn
					if (current_player != player_list[0]):
						ai_act()

func store_to_history(actor, state, board, op, prob):
	history.append({
		"actor": actor,
		"state": state,
		"board_state": convert_board_to_board_state(board),
		"op": op,
		"prob": prob
	})

func save_history():
	var history_dict = {}
	
	for ix in len(history):
		var v = history[ix]
		
		history_dict[ix] = v

	# write to file
	if not DirAccess.dir_exists_absolute(HISTORY_SAVED_DIR):
		var error_code = DirAccess.make_dir_recursive_absolute(HISTORY_SAVED_DIR)
		if error_code != OK:
			return
	
	var save_path = HISTORY_SAVED_DIR + "/" + str(Time.get_ticks_msec()) + '.json'
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(history_dict, "\t"))

func convert_board_to_board_state(board):
	var ret = {}
	for n in range(Global.MAXR * Global.MAXC):
		if (board[n] != null):
			var chess = {
				"player": 0 if board[n].player == player_list[0] else 1,
				"chess": board[n].name,
				"is_front": board[n].is_front
			}
			
			ret[n] = chess
			
	return ret

func emit_message():
	var msg
	
	match (current_state):
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE:
			msg = tr("MAIN_MSG_SUMMON_FIRST_FOOTMAN") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_SUMMON_FOOTMANS")
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			msg = tr("MAIN_MSG_SUMMON_SECOND_FOOTMAN") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_SUMMON_FOOTMANS")
		GAMESTATE.CHOOSECHESS:
			msg =  tr("MAIN_MSG_CHOOSE_CHESS") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
		GAMESTATE.CHOOSEACTION:
			msg = tr("MAIN_MSG_CHOOSE_ACTION") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
		GAMESTATE.CHOOSEDESTONE:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[summon_chess]
					
					msg = tr("MAIN_MSG_SUMMON") % [chess_model.get_tr_name()] if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
				ChessModel.ACTION_TYPE.MOVE:
					msg = tr("MAIN_MSG_MOVE") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = tr("MAIN_MSG_COMMAND") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
		GAMESTATE.CHOOSEDESTTWO:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					msg = tr("MAIN_MSG_CONFIRM_SUMMON") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = tr("MAIN_MSG_CHOOSE_COMMAND") if (current_player == player_list[0]) else tr("MAIN_MSG_AI_ACTION")
		GAMESTATE.ENDSTATE:
			msg = tr("MAIN_MSG_ONLINE_WIN") if not check_player_loss(true) else tr("MAIN_MSG_ONLINE_LOSE")

	game_message.emit(msg)

func emit_after_move_animation():
	super()
	
	if (current_state == GAMESTATE.ENDSTATE):
		history.append({"winner": 0 if not check_player_loss(true) else 1})
		save_history()
