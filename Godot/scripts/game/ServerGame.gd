extends LocalGame

class_name ServerGame

signal client_connected
signal client_disconnected
signal online_game_started
signal peer_disconnected

const _IS_DEBUG:bool = false

const WEBSOCKET_URL = "http://" + ("localhost" if _IS_DEBUG else "175.178.11.87:4115") + "/socket.io/"
const NAMESPACE = "/dukechess" # NO / AT THE END!!!

var _client
var _is_client_ready = false

func _init(main):
	_client = SocketIOClient.new(WEBSOCKET_URL)
	
	_client.on_engine_connected.connect(_on_socket_ready)
	_client.on_connect.connect(_on_socket_connect)
	_client.on_event.connect(_on_socket_event)
	_client.on_disconnect.connect(_on_socket_disconnect)
	
	main.add_child(_client)

func _on_socket_connect(_payload: Variant, _name_space, error: bool):
	if (_name_space == NAMESPACE):
		_client.socketio_send("platform", "unity", NAMESPACE)
		
		client_connected.emit()

func _on_socket_ready(_sid: String):
	_is_client_ready = true

func _on_socket_event(event_name: String, payload: Variant, _name_space):
	if (_name_space == NAMESPACE):
		if (_IS_DEBUG):
			print(event_name, " ", payload)
		
		match event_name:
			"game":
				if (payload["connection"] == "false"):
					game_message.emit(tr("MAIN_MSG_JOIN_WAIT"))
					
					peer_disconnected.emit()
				else:
					var type = payload.get("type")
					if (type != null):
						match payload["type"]:
							"init":
								game_start()
								
								current_player = player_list[0] if (payload["firstplayer"] == "true") else player_list[1]
							
								online_game_started.emit()
							
							"color":
								emit_cover_effects_from_server(payload)
								emit_message()
								
							"game", "gameover":
								perform_op_for_server(payload["userop"], payload.get("summon"))
								
								emit_cover_effects_from_server(payload)
								emit_message()

func _on_socket_disconnect(name_space: String):
	# TODO
	game_message.emit(tr("MAIN_MSG_DISCONNECT"))
	client_disconnected.emit()

func _exit_tree():
	# optional: disconnect from socketio server
	_client.socketio_disconnect()

func websocket_connect():
	if (_is_client_ready):
		_client.socketio_connect(NAMESPACE)
		return true
	else:
		game_message.emit(tr("MAIN_MSG_NOT_READY"))
		return false

func convert_n_from_server(n):
	var r = Global.n_to_rc(n)[0]
	var c = Global.n_to_rc(n)[1]
	
	r = Global.MAXR - 1 - r
	
	return Global.rc_to_n(r, c)

func perform_op(user_op, is_from_menu):
	if (current_player == null or current_player != player_list[0]):
		return false
	
	return send_to_server(user_op, is_from_menu)

func send_to_server(user_op, is_from_menu):
	if (not is_from_menu):
		user_op = convert_n_from_server(user_op)
		
		var out = {}
		out["type"] = "grid_click"
		out["grid"] = "grid_" + str(user_op)
		
		_client.socketio_send("game", out, NAMESPACE)
	else:
		var out = {}
		out["type"] = "menu_click"
		
		if (user_op in ["MAIN_MENU_CANCEL", tr("MAIN_MENU_CANCEL")]):
			perform_op_for_server(0)
			out["value"] = "Cancel"
		elif (user_op in ["MAIN_MENU_SUMMON", tr("MAIN_MENU_SUMMON")]):
			out["value"] = "Summon"
		elif (user_op in ["MAIN_MENU_MOVE", tr("MAIN_MENU_MOVE")]):
			out["value"] = "Move"
		elif (user_op in ["MAIN_MENU_COMMAND", tr("MAIN_MENU_COMMAND")]):
			out["value"] = "Command"
		elif (user_op in ["MAIN_MENU_CONFIRM", tr("MAIN_MENU_CONFIRM")]):
			out["value"] = "Confirm"
		else:
			return false
				
		_client.socketio_send("game", out, NAMESPACE)
		
		return true

func perform_op_for_server(user_op, summon_chess_from_server = null):
	user_op = convert_n_from_server(user_op)
	
	cached_state = current_state # TODO: why?
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			var duke_pos = POS_DUKE0 if current_player == player_list[0] else POS_DUKE1
			
			if board[duke_pos].get_available_destinations(board, duke_pos, ChessModel.ACTION_TYPE.SUMMON).has(user_op):
				perform_action(board, board[duke_pos], ChessModel.ACTION_TYPE.SUMMON, [user_op], "Footman", current_player)
				
				if (current_state == GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO):
					current_player = player_list[1] if current_player == player_list[0] else player_list[0]
				
				current_state += 1
				
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
				
				if (current_player == player_list[0]):
					emit_show_menu(current_chess_pos)
				
			return true
			
		GAMESTATE.CHOOSEACTION:
			# TODO: magic numbers
			if (user_op in ["MAIN_MENU_CANCEL", tr("MAIN_MENU_CANCEL"), convert_n_from_server(0)]):
				current_state = GAMESTATE.CHOOSECHESS
				return true
			elif (user_op in ["MAIN_MENU_SUMMON", tr("MAIN_MENU_SUMMON"), convert_n_from_server(1)]):
				current_action = ChessModel.ACTION_TYPE.SUMMON
				summon_chess = summon_chess_from_server
				current_player.remove_chess(summon_chess_from_server)
			elif (user_op in ["MAIN_MENU_MOVE", tr("MAIN_MENU_MOVE"), convert_n_from_server(2)]):
				current_action = ChessModel.ACTION_TYPE.MOVE
			elif (user_op in ["MAIN_MENU_COMMAND", tr("MAIN_MENU_COMMAND"), convert_n_from_server(3)]):
				current_action = ChessModel.ACTION_TYPE.COMMAND
			else:
				return false
				
			if (board[current_chess_pos].get_available_actions(board, current_chess_pos).has(current_action)):
				current_state += 1
				
				return true
			else:
				return false
				
		GAMESTATE.CHOOSEDESTONE:
			# if clicking on the selected chess, then cancel action
			if (current_action != ChessModel.ACTION_TYPE.SUMMON and user_op == current_chess_pos):
				current_state = GAMESTATE.CHOOSECHESS
				
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
						
						if (current_player == player_list[0]):
							emit_show_menu(user_op)
									
						return true
			
					ChessModel.ACTION_TYPE.MOVE:
						# Special rule for Duke
						# commented out because it does not have effect locally; need to fix the server side
						#if (current_player == player_list[0]): # only has effect for local operation
						#	if board[current_chess_pos].name == "Duke":
						#		if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(user_op)):
						#			return false
						
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
			if ((user_op == convert_n_from_server(0)) or # CANCEL
				(user_op == current_chess_pos)):
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
					if (user_op == convert_n_from_server(1)): # CONFIRM
						# chess is already add, so no action needed
				
						next_turn()
						
						return true
					else:
						return false
			
				ChessModel.ACTION_TYPE.COMMAND:
					if (user_op != command_pos and
						board[current_chess_pos].get_available_destinations(board, current_chess_pos, ChessModel.ACTION_TYPE.COMMAND).has(user_op) and
						(board[user_op] == null or board[user_op].player != current_player)):
							# Special rule for Duke
							# commented out because it does not have effect locally; need to fix the server side
							#if (current_player == player_list[0]): # only has effect for local operation
							#	if board[command_pos].name == "Duke":
							#		if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(user_op)):
							#			return false
							
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

func emit_cover_effects_from_server(payload):
	var cover_effect_dict = {}
	
	for k in payload:
		if ("grid_" in k):
			var pos = convert_n_from_server(int(k.replace("grid_", "")))
			match payload[k]:
				"yellow":
					cover_effect_dict[pos] = Color.YELLOW
				"green":
					cover_effect_dict[pos] = Color.GREEN

	state_cover_effect.emit(cover_effect_dict)

# in Server mode, this function is only for hovering
func emit_cover_effects(hover_pos):
	var cover_effect_dict = {}
	
	if (hover_pos != null and len(board) != 0 and board[hover_pos] != null):
		var color = Color.BLUE if board[hover_pos].player == current_player else Color.RED
		
		if cover_effect_dict.keys().has(hover_pos):
			cover_effect_dict[hover_pos] = color
		
		for d in board[hover_pos].get_control_area(board, hover_pos):
			# Special rule for Duke
			if board[hover_pos].player == current_player:
				if board[hover_pos].name == "Duke":
					if (get_control_area_of_player(player_list[1] if current_player == player_list[0] else player_list[0]).has(d)):
						continue
			cover_effect_dict[d] = color

	if (hover_pos == null):
		state_cover_effect.emit(cover_effect_dict)
	else:
		hover_cover_effect.emit(hover_pos, cover_effect_dict)

func emit_message():
	var msg
	
	match (current_state):
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE:
			msg = tr("MAIN_MSG_SUMMON_FIRST_FOOTMAN") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_SUMMON_FOOTMANS")
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO, GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			msg = tr("MAIN_MSG_SUMMON_SECOND_FOOTMAN") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_SUMMON_FOOTMANS")
		GAMESTATE.CHOOSECHESS:
			msg =  tr("MAIN_MSG_CHOOSE_CHESS") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
		GAMESTATE.CHOOSEACTION:
			msg = tr("MAIN_MSG_CHOOSE_ACTION") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
		GAMESTATE.CHOOSEDESTONE:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					var chess_model:ChessModel = Global.chess_loader.chessmodel_dict[summon_chess]
					
					msg = tr("MAIN_MSG_SUMMON") % [chess_model.get_tr_name()] if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
				ChessModel.ACTION_TYPE.MOVE:
					msg = tr("MAIN_MSG_MOVE") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = tr("MAIN_MSG_COMMAND") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
		GAMESTATE.CHOOSEDESTTWO:
			match (current_action):
				ChessModel.ACTION_TYPE.SUMMON:
					msg = tr("MAIN_MSG_CONFIRM_SUMMON") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
				ChessModel.ACTION_TYPE.COMMAND:
					msg = tr("MAIN_MSG_CHOOSE_COMMAND") if (current_player == player_list[0]) else tr("MAIN_MSG_WAIT_ACTION")
		GAMESTATE.ENDSTATE:
			msg = tr("MAIN_MSG_ONLINE_WIN") if not check_player_loss(true) else tr("MAIN_MSG_ONLINE_LOSE")

	game_message.emit(msg)

func emit_after_move_animation():
	if (current_state == GAMESTATE.ENDSTATE):
		game_over.emit()
