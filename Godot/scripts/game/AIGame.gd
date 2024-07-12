extends LocalGame

class_name AIGame

signal close_menu

signal disable_start_button
signal enable_start_button

# for saving history
const HISTORY_SAVED_DIR = "user://history"
var history

# connection to GUI
var GUI

# for AI decision
const DEPTH = 3
const DEPTH_DECAY = 0.8

const SUMMON_SCORE = 0

var first_ai_summon_pos
var best_selection_dict

func _init(GUI):
	self.GUI = GUI

func game_start():
	super()
	
	history = []
	
	first_ai_summon_pos = null
	
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
	disable_start_button.emit()
	
	var wait_time = 0.2 + 2 * GUI._CHESS_UP_DOWN_TIME + GUI._CHESS_MOVE_TIME + GUI._CHESS_FLIP_TIME
	await GUI.get_tree().create_timer(wait_time).timeout # TODO: wait for some seconds for playing animation; it is better to be in GUI
	
	enable_start_button.emit()
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			var possible_destinations = board[POS_DUKE1].get_available_destinations(board, POS_DUKE1, ChessModel.ACTION_TYPE.SUMMON)
				
			var random_op_ix = randi() % len(possible_destinations)
			var random_op = possible_destinations[random_op_ix]
			
			if (first_ai_summon_pos == null):
				first_ai_summon_pos = random_op
			else:
				var lr = Global.n_to_rc(first_ai_summon_pos)[0]
				
				var cr = Global.n_to_rc(random_op)[0]
				
				while (lr == cr):
					random_op_ix = randi() % len(possible_destinations)
					random_op = possible_destinations[random_op_ix]
					cr = Global.n_to_rc(random_op)[0]
			
			# write to history before perform_op
			store_to_history(1, current_state, board, random_op, 1.0 / len(possible_destinations))
			
			# perform op
			super.perform_op(random_op, false)
			
			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()
		
		GAMESTATE.CHOOSECHESS:
			# calculate best op
			var score_and_dict = find_best_op(current_player, board, DEPTH)
			best_selection_dict = score_and_dict[1]
			
			# DEBUG
			print(score_and_dict[0])
			
			# find available chess
			var possible_n = []
			for n in range(Global.MAXR * Global.MAXC):
				if (board[n] != null):
					if (board[n].player == current_player):
						if len(board[n].get_available_actions(board, n)) > 0:
							possible_n.append(n)
							
			#var random_op_ix = randi() % len(possible_n)
			#var op = possible_n[random_op_ix]
			
			var op = best_selection_dict[current_state]
			
			# write to history before perform_op
			store_to_history(1, current_state, board, op, 1.0 / len(possible_n))
			
			# perform op
			super.perform_op(op, false)
			
			# still in AI's turn
			if (current_player != player_list[0]):
				ai_act()
				
		GAMESTATE.CHOOSEACTION:
			# send a signal to close menu
			close_menu.emit()
			
			var possible_actions = board[current_chess_pos].get_available_actions(board, current_chess_pos)
		
			#var random_action_ix = randi() % len(possible_actions)
			#var selected_action = possible_actions[random_action_ix]
			
			var selected_action = best_selection_dict[current_state]

			var converted_op
			match selected_action:
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
			
			#var random_op_ix = randi() % len(possible_destinations)
			#var op = possible_destinations[random_op_ix]
			
			var op = best_selection_dict[current_state]
			
			store_to_history(1, current_state, board, op, 1.0 / len(possible_destinations))

			# perform op
			super.perform_op(op, false)

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
					
					#var random_op_ix = randi() % len(possible_destinations)
					#var op = possible_destinations[random_op_ix]
					
					var op = best_selection_dict[current_state]
					
					store_to_history(1, current_state, board, op, 1.0 / len(possible_destinations))

					# perform op
					super.perform_op(op, false)
					
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

func find_best_op(player, imagined_board, depth):
	var score = 0
	var possible_selections = []
	
	if (depth == 0 or 
		board.count(null) == (Global.MAXR * Global.MAXC)): # TODO: (need confirmation) this happens when there is no chess on the board (and score is always (-)INF)
		return [score, {}]
	
	var multiplier = 1 if player == current_player else -1
	
	# set init score
	if (multiplier > 0):
		score = -INF
	else:
		score = INF
	
	# iterate all possible chess
	for n in range(Global.MAXR * Global.MAXC):
		if (imagined_board[n] != null):
			if (imagined_board[n].player == player):
				if len(imagined_board[n].get_available_actions(imagined_board, n)) > 0:

					# iterate all possible actions
					for a in imagined_board[n].get_available_actions(imagined_board, n):
						match a:
							ChessModel.ACTION_TYPE.SUMMON:
								var possible_destinations = imagined_board[n].get_available_movements(imagined_board, n, a).keys()

								for sp in possible_destinations:
									var attempt_score = SUMMON_SCORE * multiplier

									# we assume that a dummy chess is summon
									var new_imagined_board = []
									for nn in range(Global.MAXR * Global.MAXC):
										new_imagined_board.append(imagined_board[nn].duplicate() if imagined_board[nn]!= null else null)
									
									var dummy_chess = ChessInst.new("Dummy", player)
									new_imagined_board[sp] = dummy_chess
										
									attempt_score += DEPTH_DECAY * find_best_op(player_list[1] if player == player_list[0] else player_list[0], new_imagined_board, depth - 1)[0]

									if (multiplier > 0 and attempt_score > score) or (multiplier < 0 and attempt_score < score):
										score = attempt_score
									
										possible_selections = []
										possible_selections.append({
											GAMESTATE.CHOOSECHESS: n,
											GAMESTATE.CHOOSEACTION: a,
											GAMESTATE.CHOOSEDESTONE: sp
										})
									elif (attempt_score == score):
										
										score = attempt_score
								
										possible_selections.append({
											GAMESTATE.CHOOSECHESS: n,
											GAMESTATE.CHOOSEACTION: a,
											GAMESTATE.CHOOSEDESTONE: sp
										})
									
							ChessModel.ACTION_TYPE.MOVE:
								var movements = imagined_board[n].get_available_movements(imagined_board, n, a)
								for d in movements:
									# Special rule for Duke
									if imagined_board[n].name == "Duke":
										if (get_control_area_of_player(player_list[1] if player == player_list[0] else player_list[0]).has(d) and \
											not has_enemy_duke(d, player)):
											continue
									
									var attempt_score = 0
									
									if (imagined_board[d] != null and imagined_board[d].player != player):
										if (imagined_board[d].player == current_player): 
											attempt_score += get_chess_score(imagined_board[d].name) * multiplier
										else:
											attempt_score += get_chess_score(imagined_board[d].name) * multiplier
										
									# perform imagined action
									var new_imagined_board = []
									for nn in range(Global.MAXR * Global.MAXC):
										new_imagined_board.append(imagined_board[nn].duplicate() if imagined_board[nn]!= null else null)
									
									if (new_imagined_board[n].get_available_movements(new_imagined_board, n, a).get(d) == MovementManager.MOVEMENT_TYPE.STRIKE):
										new_imagined_board[d] = null
										
										new_imagined_board[n].is_front = !new_imagined_board[n].is_front
									else:
										new_imagined_board[d] = new_imagined_board[n]
										new_imagined_board[n] = null
										
										new_imagined_board[d].is_front = !new_imagined_board[d].is_front
										
									attempt_score += DEPTH_DECAY * find_best_op(player_list[1] if player == player_list[0] else player_list[0], new_imagined_board, depth - 1)[0]
									
									if (multiplier > 0 and attempt_score > score) or (multiplier < 0 and attempt_score < score):
										score = attempt_score
									
										possible_selections = []
										possible_selections.append({
											GAMESTATE.CHOOSECHESS: n,
											GAMESTATE.CHOOSEACTION: a,
											GAMESTATE.CHOOSEDESTONE: d
										})
									elif (attempt_score == score):
										score = attempt_score
								
										possible_selections.append({
											GAMESTATE.CHOOSECHESS: n,
											GAMESTATE.CHOOSEACTION: a,
											GAMESTATE.CHOOSEDESTONE: d
										})

							ChessModel.ACTION_TYPE.COMMAND:
								for command_d in imagined_board[n].get_available_movements(imagined_board, n, a): # command pos
									if (imagined_board[command_d] != null and imagined_board[command_d].player == player):
										for target_d in imagined_board[n].get_available_destinations(imagined_board, n, a): # TODO: why different?
											if (target_d != command_d and
												((imagined_board[target_d] != null and imagined_board[target_d].player != player) or imagined_board[target_d] == null)):
													# Special rule for Duke (TODO: the server side logic should also have this)
													if imagined_board[command_d].name == "Duke":
														if (get_control_area_of_player(player_list[1] if player == player_list[0] else player_list[0]).has(target_d) and \
															not has_enemy_duke(target_d, player)):
															continue

													var attempt_score = 0
													
													if (imagined_board[target_d] != null and imagined_board[target_d].player != player):
														if (imagined_board[target_d].player == current_player): # if AI's Duke is destroyed, make score even lower
															attempt_score += get_chess_score(imagined_board[target_d].name) * multiplier * 10
														else:
															attempt_score += get_chess_score(imagined_board[target_d].name) * multiplier
														
													# perform imagined action
													var new_imagined_board = []
													for nn in range(Global.MAXR * Global.MAXC):
														new_imagined_board.append(imagined_board[nn].duplicate() if imagined_board[nn]!= null else null)
													
													new_imagined_board[target_d] = new_imagined_board[command_d]
													new_imagined_board[command_d] = null
													
													new_imagined_board[n].is_front = !new_imagined_board[n].is_front
														
													attempt_score += DEPTH_DECAY * find_best_op(player_list[1] if player == player_list[0] else player_list[0], new_imagined_board, depth - 1)[0]
													
													if (multiplier > 0 and attempt_score > score) or (multiplier < 0 and attempt_score < score):
														score = attempt_score
													
														possible_selections = []
														possible_selections.append({
															GAMESTATE.CHOOSECHESS: n,
															GAMESTATE.CHOOSEACTION: a,
															GAMESTATE.CHOOSEDESTONE: command_d,
															GAMESTATE.CHOOSEDESTTWO: target_d
														})
													elif (attempt_score == score):
														score = attempt_score
												
														possible_selections.append({
															GAMESTATE.CHOOSECHESS: n,
															GAMESTATE.CHOOSEACTION: a,
															GAMESTATE.CHOOSEDESTONE: command_d,
															GAMESTATE.CHOOSEDESTTWO: target_d
														})
	
	# DEBUG
	print("depth: %s, score: %s" % [depth, score])
	
	var random_ix = randi() % len(possible_selections)
	return [score, possible_selections[random_ix]]								
	
static func get_chess_score(chess_name):
	match chess_name:
		"Duke":
			return 1000
		"Assassin":
			return 45
		"Bowman":
			return 45
		"Champion":
			return 70
		"Dragoon":
			return 50
		"Footman":
			return 20
		"General":
			return 65
		"Knight":
			return 35
		"LongBowman":
			return 25
		"Marshall":
			return 65
		"Pikeman":
			return 25
		"Priest":
			return 60
		"Ranger":
			return 60
		"Seer":
			return 60
		"Wizard":
			return 60
		_:
			return 45
