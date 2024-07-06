extends Node

class_name Game

signal add_chess(pos, chess)

signal state_cover_effect(dict)
signal hover_cover_effect(pos, dict)
signal game_message(msg)
signal show_menu(pos, items)

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

var summon_chess

func _init():
	POS_DUKE0 = Global.rc_to_n(5, 2)
	POS_DUKE1 = Global.rc_to_n(0, 3)

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
	add_chess.emit(POS_DUKE0, duke0)
	add_chess.emit(POS_DUKE1, duke1)
	
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
				return true
			else:
				return false
				
func perform_action(board, src_chess:ChessInst, action, dest_arr, target_chess_name, player):
	match action:
		ChessModel.ACTION_TYPE.SUMMON:
			var chess = ChessInst.new(target_chess_name, player)
			board[dest_arr[0]] = chess
			player.remove_chess(target_chess_name)
			
			# signal
			add_chess.emit(dest_arr[0], chess)

		ChessModel.ACTION_TYPE.MOVE:
			if (src_chess.get_available_movements(board, dest_arr[0], action).get(dest_arr[1]) == MovementManager.MOVEMENT_TYPE.STRIKE):
				board[dest_arr[1]] = null
				
				# TODO: signal remove_chess
			else:
				board[dest_arr[1]] = board[dest_arr[0]]
				board[dest_arr[0]] = null
				
				src_chess.is_front = !src_chess.is_front
				
				# TODO: singal move_chess
				# TODO: singal flip_chess
		
		ChessModel.ACTION_TYPE.COMMAND:
			board[dest_arr[1]] = board[dest_arr[0]]
			board[dest_arr[0]] = null
			
			src_chess.is_front = !src_chess.is_front
			
			# TODO: singal move_chess
			# TODO: singal flip_chess

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
		#case GameState.CHOOSECHESS:
			#for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
				#if (this.field.fieldMap[i] != null) {
					#if (this.field.fieldMap[i].player == this.currentPlayer) {
						#tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
						#ret.set(tPos, "yellow");
					#}
				#}
			#}
			#break;
		#case GameState.CHOOSEACTION:
			#tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			#ret.set(tPos, "yellow");
			#break;
		#case GameState.CHOOSEDESTONE:
			#tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			#ret.set(tPos, "yellow");
			#
			#switch (this.currentAction) {
			#case ActionType.SUMMON:
				#for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.SUMMON)) {
					#tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
					#ret.set(tPos, "yellow");
				#}
				#break;
			#case ActionType.MOVE:
				#for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.MOVE)) {
					#tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
					#switch (m) {
					#case MovementType.STRIKE: ret.set(tPos, "red"); break;
					#default: ret.set(tPos, "green"); break;
					#}
					#
				#}
				#break;
			#case ActionType.COMMAND:
				#for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.COMMAND)) {
					#if (this.field.fieldMap[i] != null && this.field.fieldMap[i].player == this.currentPlayer) {
						#tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
						#ret.set(tPos, "yellow");
					#}
				#}
				#break;
			#}
			#break;
		#case GameState.CHOOSEDESTTWO:
			#switch (this.currentAction) {
			#case ActionType.SUMMON:
				#tPos = playerOne? this.summonPos: (this.field.maxRow * this.field.maxCol - 1 - this.summonPos);
				#ret.set(tPos, "yellow");
				#
				#for (var d of this.field.fieldMap[this.summonPos].getControlArea(this.field, this.summonPos)) {
					#tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
					#ret.set(tPos, "yellow");
				#}
				#break;
			#case ActionType.COMMAND:
				#tPos = playerOne? this.commandPos: (this.field.maxRow * this.field.maxCol - 1 - this.commandPos);
				#ret.set(tPos, "blue");
				#
				#for (var d of this.field.fieldMap[this.currentChessPos].getAvailableDests(this.field, this.currentChessPos, ActionType.COMMAND)) {
					#if (d != this.commandPos &&
						#((this.field.fieldMap[d] != null && this.field.fieldMap[d].player !=this.currentPlayer) || this.field.fieldMap[d] == null)) {
						#tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
						#ret.set(tPos, "yellow");
					#}
				#}
			#}
		#}

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
			pass # TODO
			#ret = this.checkPlayerWin(playerOne)? "You win!": "You lose..."
			#break;
		
	game_message.emit(msg)
