extends Node

class_name Game

signal add_chess(pos, chess, is_no_effect)
signal remove_chess(pos)
signal move_chess(src, dest, is_flip_during_move)

signal state_cover_effect(dict)
signal hover_cover_effect(pos, dict)
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
var cached_state:GAMESTATE

var current_chess_pos
var current_action

var summon_pos
var summon_chess

var command_pos

var winner

func _init():
	POS_DUKE0 = Global.rc_to_n(5, 2)
	POS_DUKE1 = Global.rc_to_n(0, 3)
	
	board.resize(Global.MAXR * Global.MAXC)
	board.fill(null)

func game_start():
	# init player
	player_list.append(Player.new(true))
	player_list.append(Player.new(false))
	
	current_player = player_list[0]
	
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
	
	emit_cover_effects(POS_DUKE0, false)
	emit_message()
	
func get_chess_back(r, c):
	if board[Global.rc_to_n(r, c)] == null:
		return null
	else:
		var chess = board[Global.rc_to_n(r, c)]
		return [chess.name, !board[Global.rc_to_n(r, c)].is_front]

# return if the user_op is valid or not
func perform_op(user_op, is_from_menu):
	# in Local mode, no need to convert user_op based on player
	
	cached_state = current_state # TODO: why?
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			if board[POS_DUKE0].get_available_destinations(board, POS_DUKE0, ChessModel.ACTION_TYPE.SUMMON).has(user_op):
				perform_action(board, board[POS_DUKE0], ChessModel.ACTION_TYPE.SUMMON, [user_op], "Footman", player_list[0])
				
				if (current_state == GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO):
					current_player = player_list[1]
				
				current_state += 1
				
				emit_cover_effects(POS_DUKE1, false)
				emit_message()
				
				return true
			else:
				return false
				
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			if board[POS_DUKE1].get_available_destinations(board, POS_DUKE1, ChessModel.ACTION_TYPE.SUMMON).has(user_op):
				perform_action(board, board[POS_DUKE1], ChessModel.ACTION_TYPE.SUMMON, [user_op], "Footman", player_list[1])
				
				if (current_state == GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO):
					current_player = player_list[0]
				
				current_state += 1
				
				emit_cover_effects(POS_DUKE1, false)
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
				
				emit_cover_effects(user_op, false)
				emit_message()
			else:
				current_state += 1
				
				emit_show_menu(current_chess_pos)
				
			return true
			
		GAMESTATE.CHOOSEACTION:
			if (not is_from_menu):
				return false
				
			match user_op:
				"CANCEL":
					current_state = GAMESTATE.CHOOSECHESS
					return true
				"SUMMON":
					current_action = ChessModel.ACTION_TYPE.SUMMON
					summon_chess = current_player.get_random_summon_chess()
				"MOVE":
					current_action = ChessModel.ACTION_TYPE.MOVE
				"COMMAND":
					current_action = ChessModel.ACTION_TYPE.COMMAND
				_:
					return false
				
			if (board[current_chess_pos].get_available_actions(board, current_chess_pos).has(current_action)):
				current_state += 1
				
				emit_cover_effects(current_chess_pos, false)
				emit_message()
				
				return true
			else:
				return false
				
		GAMESTATE.CHOOSEDESTONE:
			# if clicking on the selected chess, then cancel action
			if (current_action != ChessModel.ACTION_TYPE.SUMMON and user_op == current_chess_pos):
				current_state = GAMESTATE.CHOOSECHESS
				
				emit_cover_effects(null, false)
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
						
						return true
			
					ChessModel.ACTION_TYPE.MOVE:
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
							return true
						else:
							return false
					_:
						current_state = GAMESTATE.CHOOSECHESS
						return true
			else:
				return false

		GAMESTATE.CHOOSEDESTTWO:
			if ((is_from_menu and user_op == "CANCEL") or
				(not is_from_menu and user_op == current_chess_pos)):
					match current_action:
						ChessModel.ACTION_TYPE.SUMMON:
							board[summon_pos] = null
							
							current_player.add_chess(summon_chess)
							
							remove_chess.emit(summon_pos)
							
							current_state = GAMESTATE.CHOOSEDESTONE
						ChessModel.ACTION_TYPE.COMMAND:
							current_state = GAMESTATE.CHOOSECHESS
					
					return true

			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					if (is_from_menu and user_op == "CONFIRM"):
						# chess is already add, so no action needed
				
						next_turn()
						
						return true
					else:
						return false
			
				ChessModel.ACTION_TYPE.COMMAND:
					if (user_op != command_pos and
						board[current_chess_pos].get_available_destinations(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND).has(user_op) and
						(board[user_op] == null or board[user_op].player != current_player)):
							perform_action(board, board[current_chess_pos], ChessModel.ACTION_TYPE.COMMAND, [command_pos, user_op], null, null)
					else:
						return false

					if (check_player_loss(true) or check_player_loss(false)):
						current_state = GAMESTATE.ENDSTATE
					else:
						next_turn()
					
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
			move_chess.emit(src_chess, src_chess, true) # same location flip

func next_turn():
	current_player = player_list[1] if (current_player == player_list[0]) else player_list[0]
	
	current_state = GAMESTATE.CHOOSECHESS

func check_player_loss(is_main_player):
	for n in range(Global.MAXR * Global.MAXC):
		if (board[n] != null and
			board[n].name == "Duke" and 
			board[n].player == player_list[0 if is_main_player else 1]):
			return false
	
	return true

# in Local mode, there is no need to convert pos by player
func emit_cover_effects(pos, is_for_hover):
	var cover_effect_dict = {}
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			for d in board[POS_DUKE0].get_available_movements(board, POS_DUKE0, ChessModel.ACTION_TYPE.SUMMON):
				cover_effect_dict[d] = Color.YELLOW
				
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			for d in board[POS_DUKE1].get_available_movements(board, POS_DUKE1, ChessModel.ACTION_TYPE.SUMMON):
				cover_effect_dict[d] = Color.YELLOW
				
		GAMESTATE.CHOOSECHESS:
			for n in range(Global.MAXR * Global.MAXC):
				if (board[n] != null):
					if (board[n].player == current_player):
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
						match movements[d]:
							MovementManager.MOVEMENT_TYPE.STRIKE:
								cover_effect_dict[d] = Color.RED
							_:
								cover_effect_dict[d] = Color.BLUE

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
								cover_effect_dict[d] = Color.YELLOW
			
	if (is_for_hover and board[pos] != null):
		var color = Color.BLUE if board[pos].player == current_player else Color.RED
		
		if cover_effect_dict.keys().has(pos):
			cover_effect_dict[pos] = color
		
		for d in board[pos].get_control_area(board, pos):
			cover_effect_dict[d] = color

	if (not is_for_hover):
		state_cover_effect.emit(cover_effect_dict)
	else:
		hover_cover_effect.emit(pos, cover_effect_dict)

func emit_show_menu(pos):
	var items = []
	
	match current_state:
		GAMESTATE.CHOOSEACTION:
			var actions = board[current_chess_pos].get_available_actions(board, current_chess_pos)
			for a in actions:
				items.append(ChessModel.ACTION_TYPE.keys()[a])
			
			items.append("CANCEL")
		GAMESTATE.CHOOSEDESTTWO:
			if (current_action == ChessModel.ACTION_TYPE.SUMMON):
				items.append("CONFIRM")
				items.append("CANCEL")
				
	show_menu.emit(pos, items)
	
func add_message_prefix_for_player(msg):
	return "[Player " + ("1] " if current_player == player_list[0] else "2] ") + msg

# in Local mode, show all information for both players, instead of just one/main player
func emit_message():
	var msg
	
	match (current_state):
		GAMESTATE.INITIALIZATION:
			msg = "Game started."
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE:
			msg = add_message_prefix_for_player("Please SUMMON your first Footman.")
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			msg = add_message_prefix_for_player("Please SUMMON your second Footman.")
		GAMESTATE.CHOOSECHESS:
			msg =  add_message_prefix_for_player("Please choose a chess to perform action.")
		GAMESTATE.CHOOSEACTION:
			msg = add_message_prefix_for_player("Please choose an action.")
		GAMESTATE.CHOOSEDESTONE:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					msg = add_message_prefix_for_player("You are now SUMMONing " + summon_chess + ".")
				ChessModel.ACTION_TYPE.MOVE:
					msg = add_message_prefix_for_player("Please choose a place to perform MOVE action.")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = add_message_prefix_for_player("Please choose a chess to COMMAND.")
		GAMESTATE.CHOOSEDESTTWO:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					msg = add_message_prefix_for_player("Please comfirm your SUMMON action.")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = add_message_prefix_for_player("Please choose a destination for COMMAND action.")
		GAMESTATE.ENDSTATE:
			msg = "Player 1 wins!" if not check_player_loss(true) else "Player 2 wins!"

	game_message.emit(msg)

func emit_after_move_animation():
	if (current_state == GAMESTATE.ENDSTATE):
		emit_message()
		game_over.emit()
	else:
		emit_cover_effects(null, false)
		emit_message()
