extends Node

const MAXR = 6
const MAXC = 6

const WINDOW_TYPE = {
	"collection": "res://scenes//CollectionWindowGUI.tscn",
}

var chess_loader:ChessLoader

func rc_to_n(r, c):
	return r * Global.MAXC + c
	
func n_to_rc(n):
	var r:int = n / Global.MAXC
	var c:int = n % Global.MAXC
	
	return [r, c]
