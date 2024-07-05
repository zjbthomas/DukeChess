extends Node

class_name Game

signal add_chess(pos, chess)

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
	
	add_chess.emit(Global.rc_to_n(5, 2), duke0)
	add_chess.emit(Global.rc_to_n(0, 3), duke1)

func get_chess_back(r, c):
	if board[Global.rc_to_n(r, c)] == null:
		return null
	else:
		var chess = board[Global.rc_to_n(r, c)]
		return [chess.name, !board[Global.rc_to_n(r, c)].is_front]
