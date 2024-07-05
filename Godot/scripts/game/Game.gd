extends Node

class_name Game

signal add_chess(pos, chess)

signal state_cover_effect(dict)
signal game_message(msg)

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

var player_list = []
var current_player

var board = []

var current_state:GAMESTATE

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
	
	board[Global.rc_to_n(5, 2)] = duke0
	board[Global.rc_to_n(0, 3)] = duke1
	
	player_list[0].remove_chess("Duke")
	player_list[1].remove_chess("Duke")
	
	# TODO: this.waitingMenu = false; - may not need anymore
	
	current_state += 1
	
	# signal
	add_chess.emit(Global.rc_to_n(5, 2), duke0)
	add_chess.emit(Global.rc_to_n(0, 3), duke1)
	
	emit_cover_effects(null, true, false)
	emit_message(true)
	

func get_chess_back(r, c):
	if board[Global.rc_to_n(r, c)] == null:
		return null
	else:
		var chess = board[Global.rc_to_n(r, c)]
		return [chess.name, !board[Global.rc_to_n(r, c)].is_front]

func convert_pos_for_player(pos, is_first_player):
	return pos if is_first_player else (Global.MAXR * Global.MAXC - 1 - pos)

func emit_cover_effects(pos, is_first_player, is_for_hover):
	if (pos != null):
		pos = convert_pos_for_player(pos, is_first_player)
	
	var cover_effect_dict = {}
	
	match current_state:
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE, GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			for d in board[Global.rc_to_n(5, 2)].get_available_movements(board, Global.rc_to_n(5, 2), ChessModel.ACTION_TYPE.SUMMON):
				cover_effect_dict[convert_pos_for_player(d, is_first_player)] = Color.YELLOW
		#case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
		#case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
			#for (var [i, m] of this.field.fieldMap[33].getAvailableMovements(this.field, 33, ActionType.SUMMON)) {
				#tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				#ret.set(tPos, "yellow");
			#}
			#break;
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
#
		#if (hover && this.field.fieldMap[pos] != null) {
			#tPos = playerOne? pos: (this.field.maxRow * this.field.maxCol - 1 - pos);
			#var color = (playerOne == (this.field.fieldMap[pos].player == this.playerList[0]))? "blue": "red";
			#
			#if (!Array.from(ret.keys()).includes(tPos)) {
				#ret.set(tPos, color);
			#}
			#
			#for (var d of this.field.fieldMap[pos].getControlArea(this.field, pos)) {
				#tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
				#ret.set(tPos, color);
			#}
		#}
	
	if (not is_for_hover):
		state_cover_effect.emit(cover_effect_dict)
	else:
		return cover_effect_dict

func emit_message(is_first_player):
	var msg
	
	match (current_state):
		GAMESTATE.INITIALIZATION:
			msg = "Game started."
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANONE:
			msg = "Please summon your first footman." if is_first_player else "Waiting another player to summon footmen."
		GAMESTATE.INITSUMMONPLAYERONEFOOTMANTWO:
			msg = "Please summon your second footman." if is_first_player else "Waiting another player to summon footmen."
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANONE:
			msg = "Please summon your first footman." if not is_first_player else "Waiting another player to summon footmen."
		GAMESTATE.INITSUMMONPLAYERTWOFOOTMANTWO:
			msg = "Please summon your second footman." if not is_first_player else "Waiting another player to summon footmen."
		#GameState.CHOOSECHESS:
			#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a chess to perform action." : "Waiting another player to perform action.";
			#break;
		#GameState.CHOOSEACTION:
			#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose an action." : "Waiting another player to perform action.";
			#break;
		#GameState.CHOOSEDESTONE:
			#switch (this.currentAction) {
			#case ActionType.SUMMON:
				#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? ("You are now summoning " + this.summonChess + ".") : "Waiting another player to perform action.";
				#break;
			#case ActionType.MOVE:
				#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a place to perform move action." : "Waiting another player to perform action.";
				#break;
			#case ActionType.COMMAND:
				#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a chess to command." : "Waiting another player to perform action.";
				#break;
			#}
			#break;
		#GameState.CHOOSEDESTTWO:
			#switch (this.currentAction) {
			#case ActionType.SUMMON:
				#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please comfirm your summon action." : "Waiting another player to perform action.";
				#break;
			#case ActionType.COMMAND:
				#ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a destination for command action." : "Waiting another player to perform action.";
				#break;
			#}
			#break;
		#GameState.ENDSTATE:
			#ret = this.checkPlayerWin(playerOne)? "You win!": "You lose..."
			#break;
		
	game_message.emit(msg)
