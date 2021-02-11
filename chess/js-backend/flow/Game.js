const Player = require("./Player");
const Field = require("./Field");
const GameState = require("./GameState.js").GameState;
const ChessType = require("../chess/ChessType").ChessType;
const ActionType = require("../chess/ActionType").ActionType;
const MovementType = require("../movement/MovementType").MovementType;

class Game {
	constructor(maxRow, maxCol) {
        this.playerList = [];
		this.playerList[0] = new Player(0, 1);
		this.playerList[1] = new Player(1, -1);
		
		this.field = new Field(maxRow, maxCol);
		this.currentState = GameState.INITIALIZATION;
		
		this.currentPlayer = this.playerList[0];
	}

	init()
	{	
		// First player King
		this.field.fieldMap[4] = this.field.chessFactory.createChess(ChessType.KING, this.playerList[0]);
		// First player Rook
		this.field.fieldMap[0] = this.field.chessFactory.createChess(ChessType.ROOK, this.playerList[0]);
		this.field.fieldMap[7] = this.field.chessFactory.createChess(ChessType.ROOK, this.playerList[0]); 
		// First player Bishop
		this.field.fieldMap[2] = this.field.chessFactory.createChess(ChessType.BISHOP, this.playerList[0]);
		this.field.fieldMap[5] = this.field.chessFactory.createChess(ChessType.BISHOP, this.playerList[0]);
		// First player Queen
		this.field.fieldMap[3] = this.field.chessFactory.createChess(ChessType.QUEEN, this.playerList[0]);
		// First player Knight
		this.field.fieldMap[1] = this.field.chessFactory.createChess(ChessType.KNIGHT, this.playerList[0]);
		this.field.fieldMap[6] = this.field.chessFactory.createChess(ChessType.KNIGHT, this.playerList[0]);
		// First player Pawn
		for (var i = 8; i <= 15; i++) {
			this.field.fieldMap[i] = this.field.chessFactory.createChess(ChessType.PAWN, this.playerList[0]);
		}
		
		// Second player King
		this.field.fieldMap[60] = this.field.chessFactory.createChess(ChessType.KING, this.playerList[1]);
		// Second player Rook
		this.field.fieldMap[56] = this.field.chessFactory.createChess(ChessType.ROOK, this.playerList[1]);
		this.field.fieldMap[63] = this.field.chessFactory.createChess(ChessType.ROOK, this.playerList[1]);
		// Second player Bishop
		this.field.fieldMap[58] = this.field.chessFactory.createChess(ChessType.BISHOP, this.playerList[1]);
		this.field.fieldMap[61] = this.field.chessFactory.createChess(ChessType.BISHOP, this.playerList[1]);
		// Second player Queen
		this.field.fieldMap[59] = this.field.chessFactory.createChess(ChessType.QUEEN, this.playerList[1]);
		// Second player Knight
		this.field.fieldMap[57] = this.field.chessFactory.createChess(ChessType.KNIGHT, this.playerList[1]);
		this.field.fieldMap[62] = this.field.chessFactory.createChess(ChessType.KNIGHT, this.playerList[1]);
		// Second player Pawn
		for (var i = 48; i <= 55; i++) {
			this.field.fieldMap[i] = this.field.chessFactory.createChess(ChessType.PAWN, this.playerList[1]);
		}
		
		
		this.waitingMenu = false;
		
		this.currentState++;
	}
	
	performState(userOp) {
		if (!this.waitingMenu) userOp = (this.currentPlayer == this.playerList[0])? userOp: (this.field.maxRow * this.field.maxCol - 1 - userOp);
		
		switch (this.currentState) {
		case GameState.INITIALIZATION:
			this.init();
			break;
		case GameState.CHOOSECHESS:
			if (this.field.fieldMap[userOp] == null) return false;
			
			if (this.field.fieldMap[userOp].player != this.currentPlayer) return false;
			
			this.currentChessPos = userOp;
			
			this.waitingMenu = true;
			this.currentState++;
			break;
		case GameState.CHOOSEACTION:
			if (userOp == 0) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return false;
			}
			
			switch (userOp) {
			case 1: this.currentAction = ActionType.MOVE; break;
			case 2: this.currentAction = ActionType.CASTLING; break;
			default: return false;
			}
			
			if (this.field.fieldMap[this.currentChessPos].getAvailableActions(this.field, this.currentChessPos).includes(this.currentAction)) {
				this.waitingMenu = false;
				this.currentState++;
			} else return false;
			break;
		case GameState.CHOOSEDEST:
			if (userOp == this.currentChessPos) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return false;
			}
			
			if (this.field.fieldMap[this.currentChessPos].getAvailableDests(this.field, this.currentChessPos, this.currentAction).includes(userOp)) {
				this.postPos = this.field.fieldMap[this.currentChessPos].performAction(this.field, this.currentAction, [this.currentChessPos, userOp], null, null);
				
				// promotion for Pawns
				if (this.postPos != null) {
					if (Math.floor(this.postPos / this.field.maxRow) == (this.currentPlayer == this.playerList[0]? this.field.maxRow - 1: 0)) {
						this.waitingMenu = true;
						this.currentState = GameState.PROMOTE;
						break;
					}
				}

				if (this.checkPlayerWin(true) || this.checkPlayerWin(false)) {
					this.waitingMenu = false;
					this.currentState = GameState.ENDSTATE;
					return true;
				} else {
					this.nextTurn();
				}
			} else return false;
			break;
		case GameState.PROMOTE:
			if (userOp == 0) {
				this.postPos = null;

				if (this.checkPlayerWin(true) || this.checkPlayerWin(false)) {
					this.waitingMenu = false;
					this.currentState = GameState.ENDSTATE;
					return true;
				} else {
					this.nextTurn();
				}
			} else {
				switch (userOp) {
				case 1: // Rook
					this.field.fieldMap[this.postPos] = this.field.chessFactory.createChess(ChessType.ROOK, this.currentPlayer);
					this.field.fieldMap[this.postPos].CASTLING = false;
					break;
				case 2: // Bishop
					this.field.fieldMap[this.postPos] = this.field.chessFactory.createChess(ChessType.BISHOP, this.currentPlayer);
					break;
				case 3: // Queen
					this.field.fieldMap[this.postPos] = this.field.chessFactory.createChess(ChessType.QUEEN, this.currentPlayer);
					break;
				case 4: // Knight
					this.field.fieldMap[this.postPos] = this.field.chessFactory.createChess(ChessType.KNIGHT, this.currentPlayer);
					break;
				}
				this.postPos = null;
				this.nextTurn();
			}
			
			
			break;
		}
		return false;
	}
	
	nextTurn() {
		// clear current player's Pawn's capture
		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i]!= null &&
				this.field.fieldMap[i].chessType == ChessType.PAWN &&
				this.field.fieldMap[i].player == this.currentPlayer) {
					this.field.fieldMap[i].capture = null;
			}
		}

		this.currentPlayer = (this.currentPlayer == this.playerList[0])? this.playerList[1]: this.playerList[0];
		
		this.waitingMenu = false;
		this.currentState = GameState.CHOOSECHESS;
	}
	
	checkPlayerWin(playerOne) {
		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i]!= null &&
				this.field.fieldMap[i].chessType == ChessType.KING &&
				this.field.fieldMap[i].player == (this.playerList[(playerOne? 1: 0)])) return false;
		}
		return true;
	}
	
	getChessMap(playerOne) {
		var ret = new Map();
		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i] != null) {
				var pos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				var chess = "url(image/" +
							   this.field.fieldMap[i].chessType.toString() +
							   "_" +
							   (playerOne == (this.field.fieldMap[i].player == this.playerList[0])? 0: 1) +
							   ".png)";
				ret.set(pos, chess);
			}
		}
		return ret;
	}
	
	getColorMap(playerOne, hover, pos) {
		var pos = playerOne? pos: (this.field.maxRow * this.field.maxCol - 1 - pos);
		
		var ret = new Map();
		
		var tPos;
		switch (this.currentState) {
		case GameState.CHOOSECHESS:
			for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
				if (this.field.fieldMap[i] != null) {
					if (this.field.fieldMap[i].player == this.currentPlayer) {
						tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
						ret.set(tPos, "yellow");
					}
				}
			}
			break;
		case GameState.CHOOSEACTION:
			tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			ret.set(tPos, "yellow");
			break;
		case GameState.CHOOSEDEST:
			tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			ret.set(tPos, "yellow");
			
			for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, this.currentAction)) {
				tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				switch (m) {
					case MovementType.CAPTURE: ret.set(tPos, "red"); break;
					default: ret.set(tPos, "green"); break;
				}
				
			}

			break;
		case GameState.PROMOTE:
			tPos = playerOne? this.postPos: (this.field.maxRow * this.field.maxCol - 1 - this.postPos);
			ret.set(tPos, "yellow");
			break;
		}
	
		if (hover && this.field.fieldMap[pos] != null) {
			tPos = playerOne? pos: (this.field.maxRow * this.field.maxCol - 1 - pos);
			var color = (playerOne == (this.field.fieldMap[pos].player == this.playerList[0]))? "blue": "red";
			
			if (!Array.from(ret.keys()).includes(tPos)) {
				ret.set(tPos, color);
			}
			
			if (this.field.fieldMap[pos].chessType == ChessType.PAWN) {
				for (var d of this.field.fieldMap[pos].getControlAreaPawn(this.field, pos, (playerOne == (this.field.fieldMap[pos].player == this.playerList[0])))) {
					tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
					ret.set(tPos, color);
				}
			} else {
				for (var d of this.field.fieldMap[pos].getControlArea(this.field, pos)) {
					tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
					ret.set(tPos, color);
				}
			}
			
		}
			
		return ret;
	}
	
	getMenu() {
		var ret = [];
		
		switch (this.currentState) {
		case GameState.CHOOSEACTION:
			for (var action of this.field.fieldMap[this.currentChessPos].getAvailableActions(this.field, this.currentChessPos)) {
				ret = ret.concat(action);
			}
			ret =  ret.concat("Cancel");
			break;
		case GameState.PROMOTE:
			ret =  ret.concat("Rook");
			ret =  ret.concat("Bishop");
			ret =  ret.concat("Queen");
			ret =  ret.concat("Knight");
			ret =  ret.concat("Cancel");
		}
		
		return ret;
	}
	
	getMessage(playerOne) {
		var ret = "";
		
		switch (this.currentState) {
		case GameState.CHOOSECHESS:
			ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a chess to perform action." : "Waiting another player to perform action.";
			break;
		case GameState.CHOOSEACTION:
			ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose an action." : "Waiting another player to perform action.";
			break;
		case GameState.CHOOSEDEST:
			switch (this.currentAction) {
			case ActionType.MOVE:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a place to perform move action." : "Waiting another player to perform action.";
				break;
			case ActionType.CASTLING:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a rook to perform castling." : "Waiting another player to perform castling.";
				break;
			}
			break;
		case GameState.PROMOTE:
			ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a piece to promote." : "Waiting another player to perform promotion.";
			break;
		}
		
		return ret;
	}
	
	getCurrentPlayer() {
		return (this.playerList[0] == this.currentPlayer)? 0: 1;
	}
}

module.exports = Game;