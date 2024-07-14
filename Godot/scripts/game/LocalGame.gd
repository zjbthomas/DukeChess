extends Node

class_name LocalGame

signal add_chess(pos, chess, is_no_effect)
signal remove_chess(pos)
signal move_chess(src, dest, is_flip_during_move)

signal state_cover_effect(dict)
signal hover_cover_effect(pos, dict)
signal hover_control_area_cover_effect(dict)
signal game_message(msg)
signal show_menu(pos, items)

signal game_over

enum GAMESTATE {
	INITIALIZATION,
	INITSUMMONPLAYERONEFOOTMANONE,
	INITSUMMONPLAYERONEFOOTMANTWO,
	INITSUMMONPLAYERTWOFOOTMANONE,
	INITSUMMONPLAYERTWOFOOTMANTWO,
	CHOOSECHESS,
	CHOOSEACTION,
	CHOOSEDESTONE,
	CHOOSEDESTTWO,
	ENDSTATE
}

var POS_DUKE0
var POS_DUKE1

var player_list = []
var current_player:Player

var board = []

var current_state:GAMESTATE

var current_chess_pos
var current_action

var summon_pos
var summon_chess

var command_pos

var winner

func _init():
	board.resize(Global.MAXR * Global.MAXC)
	board.fill(null)

func game_start():
	# init Duke pos
	POS_DUKE0 = Global.rc_to_n(5, 2)
	POS_DUKE1 = Global.rc_to_n(0, 3)
	
	# init player
	player_list = []
	
	player_list.append(Player.new(true))
	player_list.append(Player.new(false))
	
	# randomly select a starting player
	var random_index = randi() % 2
	current_player = player_list[random_index]
	
	# init board
	board.resize(Global.MAXR * Global.MAXC)
	board.fill(null)

	current_state = GAMESTATE.INITIALIZATION
	
	# add two Dukes
	var duke0 = ChessInst.new("Duke", player_list[0])
	var duke1 = ChessInst.new("Duke", player_list[1])
	
	board[POS_DUKE0] = duke0 # TODO: magic numbers
	board[POS_DUKE1] = duke1
	
	player_list[0].remove_chess("Duke")
	player_list[1].remove_chess("Duke")
	
	current_state += 1
	
	# signal
	add_chess.emit(POS_DUKE0, duke0, true)
	add_chess.emit(POS_DUKE1, duke1, true)
	
	emit_cover_effects(null)
	emit_message()
	
func get_chess(r, c):
	if len(board) == 0 or board[Global.rc_to_n(r, c)] == null:
		return null
	else:
		return board[Global.rc_to_n(r, c)]

func get_control_area_of_player(board, player):
	if len(board) == 0:
		return null
	
	var ret = []
	
	for n in range(Global.MAXR * Global.MAXC):
		var chess:ChessInst = board[n]
		if (chess != null and chess.player == player):
			var control_area = chess.get_control_area(board, n)
			for pos in control_area:
				# Special rule for Duke
				if player == current_player:
					var is_safe_d = true
					for a in board[n].get_available_actions(board, n):
						match a:
							ChessModel.ACTION_TYPE.MOVE:
								if not _is_duke_safe_after_action(board, n, board[n].player, a, pos):
									is_safe_d = false
									break
							ChessModel.ACTION_TYPE.COMMAND:
								pass # TODO: no filtering for COMMAND
					
					if (not is_safe_d):
						continue
				
				#if (player == current_player):
				#	if chess.name == "Duke":
				#		if (get_control_area_of_player(board, player_list[1] if player == player_list[0] else player_list[0]).has(pos) and \
				#			not has_enemy_duke(pos, player)):
				#			continue
				
				if not ret.has(pos):
					ret.append(pos)
					
	return ret

func has_enemy_duke(pos, player):
	if (len(board) != 0 and board[pos] != null and \
		board[pos].name == "Duke" and board[pos].player != player):
			return true
	else:
		return false

# return if the user_op is valid or not
func perform_op(user_op, is_from_menu):
	# in Local mode, no need to convert user_op based on player
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			var duke_pos = POS_DUKE0 if current_player == player_list[0] else POS_DUKE1
			
			if board[duke_pos].get_available_destinations(board, duke_pos, ChessModel.ACTION_TYPE.SUMMON).has(user_op):
				perform_action(board, board[duke_pos], ChessModel.ACTION_TYPE.SUMMON, [user_op], "Footman", current_player)
				
				if (current_state == GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO):
					current_player = player_list[1] if current_player == player_list[0] else player_list[0]
				
				current_state += 1
				
				emit_cover_effects(null)
				emit_message()
				
				return true
			else:
				return false
				
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			var duke_pos = POS_DUKE0 if current_player == player_list[0] else POS_DUKE1
			
			if board[duke_pos].get_available_destinations(board, duke_pos, ChessModel.ACTION_TYPE.SUMMON).has(user_op):
				perform_action(board, board[duke_pos], ChessModel.ACTION_TYPE.SUMMON, [user_op], "Footman", current_player)
				
				if (current_state == GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO):
					current_player = player_list[0] if current_player == player_list[1] else player_list[1]
				
				current_state += 1
				
				emit_cover_effects(null)
				emit_message()
				
				return true
			else:
				return false
				
		GAMESTATE.CHOOSECHESS:
			if board[user_op] == null:
				return false
			
			if board[user_op].player != current_player:
				return false

			current_chess_pos = user_op

			var actions = board[current_chess_pos].get_available_actions(board, current_chess_pos)

			# no action means invalid chess selection
			if (len(actions) == 0):
				return false
			
			if (len(actions) == 1 and actions[0] != ChessModel.ACTION_TYPE.SUMMON):
				# if there is only one possible action, use it
				current_action = actions[0]
				
				# skip CHOOSEACTION stage
				current_state = GAMESTATE.CHOOSEDESTONE
				
				emit_cover_effects(null)
				emit_message()
			else:
				current_state += 1
				
				emit_show_menu(current_chess_pos)
				
				emit_cover_effects(null)
				emit_message()
				
			return true
			
		GAMESTATE.CHOOSEACTION:
			if (not is_from_menu):
				return false
			
			if (user_op in ["MAIN_MENU_CANCEL", tr("MAIN_MENU_CANCEL")]):
				current_state = GAMESTATE.CHOOSECHESS
				
				emit_cover_effects(null)
				emit_message()
				
				return true
			elif (user_op in ["MAIN_MENU_SUMMON", tr("MAIN_MENU_SUMMON")]):
				current_action = ChessModel.ACTION_TYPE.SUMMON
				summon_chess = current_player.get_random_summon_chess()
			elif (user_op in ["MAIN_MENU_MOVE", tr("MAIN_MENU_MOVE")]):
				current_action = ChessModel.ACTION_TYPE.MOVE
			elif (user_op in ["MAIN_MENU_COMMAND", tr("MAIN_MENU_COMMAND")]):
				current_action = ChessModel.ACTION_TYPE.COMMAND
			else:
				return false
				
			if (board[current_chess_pos].get_available_actions(board, current_chess_pos).has(current_action)):
				current_state += 1
				
				emit_cover_effects(null)
				emit_message()
				
				return true
			else:
				return false
				
		GAMESTATE.CHOOSEDESTONE:
			# if clicking on the selected chess, then cancel action
			if (current_action != ChessModel.ACTION_TYPE.SUMMON and user_op == current_chess_pos):
				current_state = GAMESTATE.CHOOSECHESS
				
				emit_cover_effects(null)
				emit_message()
				
				return true
			
			if board[current_chess_pos].get_available_destinations(board, current_chess_pos, current_action).has(user_op):
				match current_action:
					ChessModel.ACTION_TYPE.SUMMON:
						# temporarily add a chees to board and wait for user confirmation
						var chess = ChessInst.new(summon_chess, current_player)
						board[user_op] = chess
						
						current_player.remove_chess(summon_chess)
						
						add_chess.emit(user_op, chess, false)
						
						summon_pos = user_op
						
						current_state = GAMESTATE.CHOOSEDESTTWO
						
						emit_show_menu(user_op)
						
						emit_cover_effects(null)
						emit_message()
						
						return true
			
					ChessModel.ACTION_TYPE.MOVE:
						# Special rule for Duke
						if not _is_duke_safe_after_action(board, current_chess_pos, current_player, current_action, user_op):
							return false
				
						#if board[current_chess_pos].name == "Duke":
						#	if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(user_op) and \
						#		not has_enemy_duke(user_op, current_player)):
						#		return false
						
						perform_action(board, board[current_chess_pos], current_action, [current_chess_pos, user_op], null, null)

						if (check_player_loss(true) or check_player_loss(false)):
							current_state = GAMESTATE.ENDSTATE
						else:
							next_turn()
							
						# emit will be done after move animation, see emit_after_move_animation()
						
						return true
						
					ChessModel.ACTION_TYPE.COMMAND:
						if (board[user_op] != null and board[user_op].player == current_player):
							command_pos = user_op
							
							current_state = GAMESTATE.CHOOSEDESTTWO
							
							emit_cover_effects(null)
							emit_message()
							
							return true
						else:
							return false
					_:
						current_state = GAMESTATE.CHOOSECHESS
						
						emit_cover_effects(null)
						emit_message()
						
						return true
			else:
				return false

		GAMESTATE.CHOOSEDESTTWO:
			if ((is_from_menu and user_op in ["MAIN_MENU_CANCEL", tr("MAIN_MENU_CANCEL")]) or
				(not is_from_menu and user_op == current_chess_pos)):
					match current_action:
						ChessModel.ACTION_TYPE.SUMMON:
							board[summon_pos] = null
							
							current_player.add_chess(summon_chess)
							
							remove_chess.emit(summon_pos)
							
							current_state = GAMESTATE.CHOOSEDESTONE
						ChessModel.ACTION_TYPE.COMMAND:
							current_state = GAMESTATE.CHOOSECHESS
					
					emit_cover_effects(null)
					emit_message()
					
					return true

			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					if (is_from_menu and user_op in ["MAIN_MENU_CONFIRM", tr("MAIN_MENU_CONFIRM")]):
						# chess is already add, so no action needed
				
						next_turn()
						
						emit_cover_effects(null)
						emit_message()
						
						return true
					else:
						return false
			
				ChessModel.ACTION_TYPE.COMMAND:
					if (user_op != command_pos and
						board[current_chess_pos].get_available_destinations(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND).has(user_op) and
						(board[user_op] == null or board[user_op].player != current_player)):
							# Special rule for Duke
							if not _is_duke_safe_after_action(board, current_chess_pos, current_player, current_action, user_op, command_pos):
								return false
								
							#if board[command_pos].name == "Duke":
							#	if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(user_op) and \
							#		not has_enemy_duke(user_op, current_player)):
							#		return false
							
							perform_action(board, board[current_chess_pos], ChessModel.ACTION_TYPE.COMMAND, [command_pos, user_op], null, null)
					else:
						return false

					if (check_player_loss(true) or check_player_loss(false)):
						current_state = GAMESTATE.ENDSTATE
					else:
						next_turn()
						
						# emit will be done after move animation, see emit_after_move_animation()
					
					return true

			return false
			
	return false
				
func perform_action(board, src_chess:ChessInst, action, dest_arr, target_chess_name, player):
	match action:
		ChessModel.ACTION_TYPE.SUMMON: # this is just for summoning the first 2*2 Footmans
			var chess = ChessInst.new(target_chess_name, player)
			board[dest_arr[0]] = chess
			player.remove_chess(target_chess_name)
			
			# signal
			add_chess.emit(dest_arr[0], chess, false)
			
		ChessModel.ACTION_TYPE.MOVE:
			if (src_chess.get_available_movements(board, dest_arr[0], action).get(dest_arr[1]) == MovementManager.MOVEMENT_TYPE.STRIKE):
				board[dest_arr[1]] = null
				
				remove_chess.emit(dest_arr[1])
				
				src_chess.is_front = !src_chess.is_front
				
				move_chess.emit(current_chess_pos, current_chess_pos, true) # same location flip
			else:
				board[dest_arr[1]] = board[dest_arr[0]]
				board[dest_arr[0]] = null
				
				src_chess.is_front = !src_chess.is_front
				
				move_chess.emit(dest_arr[0], dest_arr[1], true) # move and flip
		
		ChessModel.ACTION_TYPE.COMMAND:
			board[dest_arr[1]] = board[dest_arr[0]]
			board[dest_arr[0]] = null
			
			src_chess.is_front = !src_chess.is_front
			
			move_chess.emit(dest_arr[0], dest_arr[1], false)
			move_chess.emit(current_chess_pos, current_chess_pos, true) # same location flip

func next_turn():
	current_player = player_list[1] if (current_player == player_list[0]) else player_list[0]
	
	current_state = GAMESTATE.CHOOSECHESS

func check_player_loss(is_main_player):
	for n in range(Global.MAXR * Global.MAXC):
		if (board[n] != null and
			board[n].name == "Duke" and 
			board[n].player == player_list[0 if is_main_player else 1]):
	
			if (has_available_movement(player_list[0 if is_main_player else 1], board)):
				return false
	
	return true

func check_dukes_being_checkmated():
	var ret = []
	
	for n in range(Global.MAXR * Global.MAXC):
		if (len(board) != 0 and board[n] != null and board[n].name == "Duke"):
			if (get_control_area_of_player(board, player_list[0] if board[n].player == player_list[1] else player_list[1]).has(n)):
				ret.append(n)
	
	return ret

# in Local mode, there is no need to convert pos by player
func emit_cover_effects(hover_pos):
	var cover_effect_dict = {}
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			var duke_pos = POS_DUKE0 if current_player == player_list[0] else POS_DUKE1
			
			for d in board[duke_pos].get_available_movements(board, duke_pos, ChessModel.ACTION_TYPE.SUMMON):
				cover_effect_dict[d] = Color.YELLOW
				
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			var duke_pos = POS_DUKE0 if current_player == player_list[0] else POS_DUKE1
			
			for d in board[duke_pos].get_available_movements(board, duke_pos, ChessModel.ACTION_TYPE.SUMMON):
				cover_effect_dict[d] = Color.YELLOW
				
		GAMESTATE.CHOOSECHESS:
			for n in range(Global.MAXR * Global.MAXC):
				if (board[n] != null):
					if (board[n].player == current_player):
						if len(board[n].get_available_actions(board, n)) > 0:
							cover_effect_dict[n] = Color.YELLOW
						
		GAMESTATE.CHOOSEACTION:
			cover_effect_dict[current_chess_pos] = Color.YELLOW

		GAMESTATE.CHOOSEDESTONE:
			cover_effect_dict[current_chess_pos] = Color.YELLOW
			
			match current_action:
				ChessModel.ACTION_TYPE.SUMMON:
					for d in board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.SUMMON):
						cover_effect_dict[d] = Color.YELLOW
			
				ChessModel.ACTION_TYPE.MOVE:
					var movements = board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.MOVE)
					for d in movements:
						# Special rule for Duke
						if not _is_duke_safe_after_action(board, current_chess_pos, current_player, current_action, d):
							continue
						
						#if board[current_chess_pos].name == "Duke":
						#	if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d) and \
						#		not has_enemy_duke(d, current_player)):
						#		continue
						
						match movements[d]:
							MovementManager.MOVEMENT_TYPE.STRIKE:
								cover_effect_dict[d] = Color.RED
							_:
								cover_effect_dict[d] = Color.GREEN

				ChessModel.ACTION_TYPE.COMMAND:
					for d in board[current_chess_pos].get_available_movements(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND):
						if (board[d] != null and board[d].player == current_player):
							cover_effect_dict[d] = Color.YELLOW

		GAMESTATE.CHOOSEDESTTWO:
			match current_action:
				ChessModel.ACTION_TYPE.SUMMON:
					cover_effect_dict[summon_pos] = Color.YELLOW
					
					for d in board[summon_pos].get_control_area(board, summon_pos):
						cover_effect_dict[d] = Color.YELLOW
						
				ChessModel.ACTION_TYPE.COMMAND:
					cover_effect_dict[command_pos] = Color.BLUE
					
					for d in board[current_chess_pos].get_available_destinations(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND):
						if (d != command_pos and
							((board[d] != null and board[d].player != current_player) or board[d] == null)):
								# Special rule for Duke (TODO: the server side logic should also have this)
								if not _is_duke_safe_after_action(board, current_chess_pos, current_player, current_action, d, command_pos):
									return false
								
								#if board[command_pos].name == "Duke":
								#	if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d) and \
								#		not has_enemy_duke(d, current_player)):
								#		continue
								
								cover_effect_dict[d] = Color.YELLOW
	
	# check if any Duke is being checkmated
	for n in check_dukes_being_checkmated():
		cover_effect_dict[n] = Color.RED
	
	if (hover_pos != null and len(board) != 0 and board[hover_pos] != null):
		var color = Color.BLUE if board[hover_pos].player == current_player else Color.RED
		
		if cover_effect_dict.keys().has(hover_pos):
			cover_effect_dict[hover_pos] = color
		
		for d in board[hover_pos].get_control_area(board, hover_pos):
			# Special rule for Duke
			if board[hover_pos].player == current_player:
				var is_safe_d = true
				for a in board[hover_pos].get_available_actions(board, hover_pos):
					match a:
						ChessModel.ACTION_TYPE.MOVE:
							if not _is_duke_safe_after_action(board, hover_pos, board[hover_pos].player, a, d):
								is_safe_d = false
								break
						ChessModel.ACTION_TYPE.COMMAND:
							pass # TODO: no filtering for COMMAND
				
				if (not is_safe_d):
					continue
				
				#if board[hover_pos].name == "Duke":
				#	if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d) and \
				#		not has_enemy_duke(d, current_player)):
				#		continue
			
			cover_effect_dict[d] = color

	if (hover_pos == null):
		state_cover_effect.emit(cover_effect_dict)
	else:
		hover_cover_effect.emit(hover_pos, cover_effect_dict)

func _is_duke_safe_after_action(board, chess_pos, player, action, op_pos, command_pos=null):
	match action:
		ChessModel.ACTION_TYPE.MOVE:
			var imagined_board = []
			for nn in range(Global.MAXR * Global.MAXC):
				imagined_board.append(board[nn].duplicate() if board[nn]!= null else null)
			
			if (imagined_board[chess_pos].get_available_movements(imagined_board, chess_pos, action).get(op_pos) == MovementManager.MOVEMENT_TYPE.STRIKE):
				imagined_board[op_pos] = null
				
				imagined_board[chess_pos].is_front = !imagined_board[chess_pos].is_front
			else:
				imagined_board[op_pos] = imagined_board[chess_pos]
				imagined_board[chess_pos] = null
				
				imagined_board[op_pos].is_front = !imagined_board[op_pos].is_front
			
			var duke_under_control = false
			var found_enemy_duke = false
			for nn in range(Global.MAXR * Global.MAXC):
				if (imagined_board[nn] != null and imagined_board[nn].name == "Duke"):
					if (imagined_board[nn].player == player):
						if (get_control_area_of_player(imagined_board, player_list[1] if player == player_list[0] else player_list[0]).has(nn) and \
							not has_enemy_duke(nn, player)):
							duke_under_control = true
					else:
						found_enemy_duke = true
						
			if (found_enemy_duke and duke_under_control):
				return false
					
		ChessModel.ACTION_TYPE.COMMAND:
			var imagined_board = []
			for nn in range(Global.MAXR * Global.MAXC):
				imagined_board.append(board[nn].duplicate() if board[nn]!= null else null)
			
			imagined_board[op_pos] = imagined_board[command_pos]
			imagined_board[command_pos] = null
			
			imagined_board[chess_pos].is_front = !imagined_board[chess_pos].is_front

			var duke_under_control = false
			var found_enemy_duke = false
			for nn in range(Global.MAXR * Global.MAXC):
				if (imagined_board[nn] != null and imagined_board[nn].name == "Duke"):
					if (imagined_board[nn].player == player):
						if (get_control_area_of_player(imagined_board, player_list[1] if player == player_list[0] else player_list[0]).has(nn) and \
							not has_enemy_duke(nn, player)):
							duke_under_control = true
					else:
						found_enemy_duke = true
			
			if (found_enemy_duke and duke_under_control):
				return false
				
	return true

func emit_control_area_cover_effects(player):
	var cover_effect_dict = {}
	
	for d in get_control_area_of_player(board, player):		
		cover_effect_dict[d] = Color.RED
		
	hover_control_area_cover_effect.emit(cover_effect_dict)

func emit_show_menu(pos):
	var items = []
	
	match current_state:
		GAMESTATE.CHOOSEACTION:
			var actions = board[current_chess_pos].get_available_actions(board, current_chess_pos)
			for a in actions:
				items.append(tr("MAIN_MENU_%s") % ChessModel.ACTION_TYPE.keys()[a])
			
			items.append(tr("MAIN_MENU_CANCEL"))
		GAMESTATE.CHOOSEDESTTWO:
			if (current_action == ChessModel.ACTION_TYPE.SUMMON):
				items.append(tr("MAIN_MENU_CONFIRM"))
				items.append(tr("MAIN_MENU_CANCEL"))
				
	show_menu.emit(pos, items)
	
func add_message_prefix_for_player(msg):
	return tr("MAIN_PLAYER1" if current_player == player_list[0] else "MAIN_PLAYER2") + " " + msg

# in Local mode, show all information for both players, instead of just one/main player
func emit_message():
	var msg
	
	match (current_state):
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE:
			msg = add_message_prefix_for_player(tr("MAIN_MSG_SUMMON_FIRST_FOOTMAN"))
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			msg = add_message_prefix_for_player(tr("MAIN_MSG_SUMMON_SECOND_FOOTMAN"))
		GAMESTATE.CHOOSECHESS:
			msg =  add_message_prefix_for_player(tr("MAIN_MSG_CHOOSE_CHESS"))
		GAMESTATE.CHOOSEACTION:
			msg = add_message_prefix_for_player(tr("MAIN_MSG_CHOOSE_ACTION"))
		GAMESTATE.CHOOSEDESTONE:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[summon_chess]
					
					msg = add_message_prefix_for_player(tr("MAIN_MSG_SUMMON") % [chess_model.get_tr_name()])
				ChessModel.ACTION_TYPE.MOVE:
					msg = add_message_prefix_for_player(tr("MAIN_MSG_MOVE"))
				ChessModel.ACTION_TYPE.COMMAND:
					msg = add_message_prefix_for_player(tr("MAIN_MSG_COMMAND"))
		GAMESTATE.CHOOSEDESTTWO:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					msg = add_message_prefix_for_player(tr("MAIN_MSG_CONFIRM_SUMMON"))
				ChessModel.ACTION_TYPE.COMMAND:
					msg = add_message_prefix_for_player(tr("MAIN_MSG_CHOOSE_COMMAND"))
		GAMESTATE.ENDSTATE:
			msg = tr("MAIN_MSG_WIN1") if not check_player_loss(true) else tr("MAIN_MSG_WIN2")

	game_message.emit(msg)

func emit_after_move_animation():
	if (current_state == GAMESTATE.ENDSTATE):
		emit_message()
		game_over.emit()
	else:
		emit_cover_effects(null)
		emit_message()

func has_available_movement(player, board):
	# iterate all possible chess
	for n in range(Global.MAXR * Global.MAXC):
		if (board[n] != null):
			if (board[n].player == player):
				if len(board[n].get_available_actions(board, n)) > 0:

					# iterate all possible actions
					for a in board[n].get_available_actions(board, n):
						match a:
							ChessModel.ACTION_TYPE.SUMMON:
								var possible_destinations = board[n].get_available_movements(board, n, a).keys()

								if (len(possible_destinations) > 0):
									return true
									
							ChessModel.ACTION_TYPE.MOVE:
								var movements = board[n].get_available_movements(board, n, a)
								for d in movements:
									# Special rule for Duke
									if _is_duke_safe_after_action(board, n, player, a, d):
										return true
										
							ChessModel.ACTION_TYPE.COMMAND:
								for command_d in board[n].get_available_movements(board, n, a): # command pos
									if (board[command_d] != null and board[command_d].player == player):
										for target_d in board[n].get_available_destinations(board, n, a): # TODO: why different?
											if (target_d != command_d and
												((board[target_d] != null and board[target_d].player != player) or board[target_d] == null)):
													# Special rule for Duke
													if _is_duke_safe_after_action(board, n, player, a, target_d, command_d):
														return true
	
	return false
