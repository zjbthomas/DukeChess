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
		this.field.fieldMap[2] = this.field.chessFactory.createChess(ChessType.DUKE, this.playerList[0]);
		this.field.fieldMap[33] = this.field.chessFactory.createChess(ChessType.DUKE, this.playerList[1]);
		
		this.playerList[0].removeFromList(ChessType.DUKE);
		this.playerList[1].removeFromList(ChessType.DUKE);
		
		this.waitingMenu = false;
		
		this.currentState++;
	}
	
	getControlAreaOfPlayer(field, player) {
		var ret = [];
		for (var i = 0; i < field.maxRow * field.maxCol; i++) {
			if (field.fieldMap[i] != null && field.fieldMap[i].player == player) {
				for (var d of field.fieldMap[i].getControlArea(field, i)) {
					// Special rule for Duke
					if (player == this.currentPlayer) {
						var isSafeD = true;
						for (var a in field.fieldMap[i].getAvailableActions(field, i)) {
							switch (a){
								case ActionType.MOVE:
									if (!this.isDukeSaveAfterAction(field, i, field.fieldMap[i].player, a, d)) {
										isSafeD = false;
									}
									break;
							}

							if (isSafeD == false) break;
						}

						if (isSafeD == false) continue;
					}

					if (!ret.includes(d)) ret = ret.concat(d);
				}
			}
		}
		return ret;
	}

	hasEnemyDuke(pos, player) {
		if (this.field.fieldMap[pos] != null && this.field.fieldMap[pos].chessType == ChessType.DUKE && this.field.fieldMap[pos].player != player) {
			return true;
		} else return false;
	}

	/*
	 * Return: if the userOp is valid
	*/
	performState(userOp) {
		if (!this.waitingMenu) {
			userOp = (this.currentPlayer == this.playerList[0])? userOp: (this.field.maxRow * this.field.maxCol - 1 - userOp);
		}

		this.cachedState = this.currentState;
		
		switch (this.currentState) {
		case GameState.INITIALIZATION:
			this.init();
			return true;
		case GameState.INITSUMMONPLAYERONEFOOTMANONE:
		case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
			if (this.field.fieldMap[2].getAvailableDests(this.field, 2, ActionType.SUMMON).includes( userOp)) {
				this.field.fieldMap[2].performAction(this.field, ActionType.SUMMON, [userOp], ChessType.FOOTMAN, this.playerList[0]);
				
				this.waitingMenu = false;
				if (this.currentState == GameState.INITSUMMONPLAYERONEFOOTMANTWO) {
					this.currentPlayer = this.playerList[1];
				}
				this.currentState++;
				return true;
			} else return false;
		case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
		case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
			if (this.field.fieldMap[33].getAvailableDests(this.field, 33, ActionType.SUMMON).includes( userOp)) {
				this.field.fieldMap[2].performAction(this.field, ActionType.SUMMON, [userOp], ChessType.FOOTMAN, this.playerList[1]);
				
				this.waitingMenu = false;
				if (this.currentState == GameState.INITSUMMONPLAYERTWOFOOTMANTWO) {
					this.currentPlayer = this.playerList[0];
				}
				this.currentState++;
				return true;
			} else return false;
		case GameState.CHOOSECHESS:
			if (this.field.fieldMap[userOp] == null) return false;
			
			if (this.field.fieldMap[userOp].player != this.currentPlayer) return false;
			
			this.currentChessPos = userOp;
			
			var actions = this.field.fieldMap[this.currentChessPos].getAvailableActions(this.field, this.currentChessPos);

			// No action, then invalid chess selection
			if (actions.length == 0) return false;

			if (actions.length == 1 && actions[0] != ActionType.SUMMON) {
				// If there is only one possible action, set it
				// And skip CHOOSEACTION stage
				this.currentAction = actions[0];

				this.waitingMenu = false;
				this.currentState = GameState.CHOOSEDESTONE;
			} else {
				this.waitingMenu = true;
				this.currentState++;
			}
			
			return true;
		case GameState.CHOOSEACTION:
			if (userOp == 0) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return true;
			}
			
			switch (userOp) {
			case 1:
				this.currentAction = ActionType.SUMMON;
				this.summonChess = this.currentPlayer.chessList[Math.floor(Math.random() * this.currentPlayer.chessList.length)];
				break;
			case 2: this.currentAction = ActionType.MOVE; break;
			case 3: this.currentAction = ActionType.COMMAND; break;
			default: return false;
			}
			
			if (this.field.fieldMap[this.currentChessPos].getAvailableActions(this.field, this.currentChessPos).includes(this.currentAction)) {
				this.waitingMenu = false;
				this.currentState++;
				return true;
			} else return false;
		case GameState.CHOOSEDESTONE:
			// If clicking on the selected chess, then cancel action
			if (this.currentAction != ActionType.SUMMON && userOp == this.currentChessPos) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return true;
			}
			
			if (this.field.fieldMap[this.currentChessPos].getAvailableDests(this.field, this.currentChessPos, this.currentAction).includes(userOp)) {
				switch (this.currentAction) {
				case ActionType.SUMMON:
					this.field.fieldMap[userOp] = this.field.chessFactory.createChess(this.summonChess, this.currentPlayer);
					this.summonPos = userOp;
					
					this.waitingMenu = true;
					this.currentState = GameState.CHOOSEDESTTWO;
					return true;
				case ActionType.MOVE:
					// Special rule for Duke
					if (!this.isDukeSaveAfterAction(this.field, this.currentChessPos, this.currentPlayer, this.currentAction, userOp)) {
						return false;
					}

					this.field.fieldMap[this.currentChessPos].performAction(this.field, ActionType.MOVE, [this.currentChessPos, userOp], null, null);
					
					if (this.checkPlayerLoss(true) || this.checkPlayerLoss(false)) {
						this.currentState = GameState.ENDSTATE;
					} else {
						this.nextTurn();
					}

					return true;
				case ActionType.COMMAND: 
					if (this.field.fieldMap[userOp] != null && this.field.fieldMap[userOp].player == this.currentPlayer) {
						this.commandPos = userOp;
						
						this.waitingMenu = false;
						this.currentState = GameState.CHOOSEDESTTWO;
						return true;
					} else return false;
				default:
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSECHESS;
					return true;
				}
			} else return false;
		case GameState.CHOOSEDESTTWO:
			if ((this.waitingMenu && userOp == 0) || (!this.waitingMenu && userOp == this.currentChessPos)) {
				switch (this.currentAction) {
				case ActionType.SUMMON:
					this.field.fieldMap[this.summonPos] = null;
					
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSEDESTONE;
					break;
				case ActionType.COMMAND:
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSECHESS;
					break;
				}
				return true;
			}
			
			switch (this.currentAction) {
			case ActionType.SUMMON:
				if (userOp == 1) {
					this.field.fieldMap[this.currentChessPos].performAction(this.field, ActionType.SUMMON, [this.summonPos], this.summonChess, this.currentPlayer);
					
					this.nextTurn();
					return true;
				} else return false;
			case ActionType.COMMAND:
				if (userOp != this.commandPos &&
					this.field.fieldMap[this.currentChessPos].getAvailableDests(this.field, this.currentChessPos, ActionType.COMMAND).includes(userOp) &&
					(this.field.fieldMap[userOp] == null || this.field.fieldMap[userOp].player != this.currentPlayer)) {
						// Speicial rule for Duke
						if (!this.isDukeSaveAfterAction(this.field, this.currentChessPos, this.currentPlayer, this.currentAction, this.commandPos)) {
							return false;
						}
	

						this.field.fieldMap[this.currentChessPos].performAction(this.field, ActionType.COMMMAND, [this.commandPos, userOp], null, null);
				} else return false;
				if (this.checkPlayerLoss(true) || this.checkPlayerLoss(false)) {
					this.currentState = GameState.ENDSTATE;
				} else {
					this.nextTurn();
				}
				return true;
			}
			return false;
		}
		return false;
	}
	
	nextTurn() {
		this.currentPlayer = (this.currentPlayer == this.playerList[0])? this.playerList[1]: this.playerList[0];
		
		this.waitingMenu = false;
		this.currentState = GameState.CHOOSECHESS;
	}
	
	checkPlayerLoss(playerOne) {
		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i]!= null &&
				this.field.fieldMap[i].chessType == ChessType.DUKE &&
				this.field.fieldMap[i].player == (this.playerList[(playerOne? 0: 1)])) {
				
				if (this.hasAvailableMovement(this.playerList[(playerOne? 0: 1)], this.field)) {
					return false;
				}
			}
		}
		return true;
	}
	
    checkDukesBeingCheckmated() {
		var ret = [];

		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i]!= null &&
				this.field.fieldMap[i].chessType == ChessType.DUKE) {
				
				if (this.getControlAreaOfPlayer(this.field, (this.field.fieldMap[i].player == this.playerList[0])? this.playerList[1]: this.playerList[0]).includes(i)) {
					ret = ret.concat(i);
				}
			}
		}

		return ret;
	}

	getChessMap(playerOne) {
		var ret = new Map();
		for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
			if (this.field.fieldMap[i] != null) {
				var pos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				var chess = "url(image/" +
							   this.field.fieldMap[i].chessType.toString() +
							   "_" +
							   (this.field.fieldMap[i].starter? "f": "b") +
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
		case GameState.INITSUMMONPLAYERONEFOOTMANONE:
		case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
			for (var [i, m] of this.field.fieldMap[2].getAvailableMovements(this.field, 2, ActionType.SUMMON)) {
				tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				ret.set(tPos, "yellow");
			}
			break;
		case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
		case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
			for (var [i, m] of this.field.fieldMap[33].getAvailableMovements(this.field, 33, ActionType.SUMMON)) {
				tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
				ret.set(tPos, "yellow");
			}
			break;
		case GameState.CHOOSECHESS:
			for(var i = 0; i < this.field.maxRow * this.field.maxCol; i++) {
				if (this.field.fieldMap[i] != null) {
					if (this.field.fieldMap[i].player == this.currentPlayer) {
						if (this.field.fieldMap[i].getAvailableActions(this.field, i).length > 0) {
							tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
							ret.set(tPos, "yellow");
						}
					}
				}
			}
			break;
		case GameState.CHOOSEACTION:
			tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			ret.set(tPos, "yellow");
			break;
		case GameState.CHOOSEDESTONE:
			tPos = playerOne? this.currentChessPos: (this.field.maxRow * this.field.maxCol - 1 - this.currentChessPos);
			ret.set(tPos, "yellow");
			
			switch (this.currentAction) {
			case ActionType.SUMMON:
				for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.SUMMON)) {
					tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
					ret.set(tPos, "yellow");
				}
				break;
			case ActionType.MOVE:
				for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.MOVE)) {
					// Special rule for Duke
					if (!this.isDukeSaveAfterAction(this.field, this.currentChessPos, this.currentPlayer, this.currentAction, i)) {
						continue;
					}

					tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
					switch (m) {
					case MovementType.STRIKE: ret.set(tPos, "red"); break;
					default: ret.set(tPos, "green"); break;
					}
					
				}
				break;
			case ActionType.COMMAND:
				for (var [i, m] of this.field.fieldMap[this.currentChessPos].getAvailableMovements(this.field, this.currentChessPos, ActionType.COMMAND)) {
					if (this.field.fieldMap[i] != null && this.field.fieldMap[i].player == this.currentPlayer) {
						tPos = playerOne? i: (this.field.maxRow * this.field.maxCol - 1 - i);
						ret.set(tPos, "yellow");
					}
				}
				break;
			}
			break;
		case GameState.CHOOSEDESTTWO:
			switch (this.currentAction) {
			case ActionType.SUMMON:
				tPos = playerOne? this.summonPos: (this.field.maxRow * this.field.maxCol - 1 - this.summonPos);
				ret.set(tPos, "yellow");
				
				for (var d of this.field.fieldMap[this.summonPos].getControlArea(this.field, this.summonPos)) {
					tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
					ret.set(tPos, "yellow");
				}
				break;
			case ActionType.COMMAND:
				tPos = playerOne? this.commandPos: (this.field.maxRow * this.field.maxCol - 1 - this.commandPos);
				ret.set(tPos, "blue");
				
				for (var d of this.field.fieldMap[this.currentChessPos].getAvailableDests(this.field, this.currentChessPos, ActionType.COMMAND)) {
					if (d != this.commandPos &&
						((this.field.fieldMap[d] != null && this.field.fieldMap[d].player !=this.currentPlayer) || this.field.fieldMap[d] == null)) {
						if (!this.isDukeSaveAfterAction(this.field, this.currentChessPos, this.currentPlayer, this.currentAction, d, this.commandPos)) {
							continue;
						}

						tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
						ret.set(tPos, "yellow");
					}
				}
			}
		}
	
		// check if any Duke is being checkmated
		for (var d of this.checkDukesBeingCheckmated()) {
			tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
			ret.set(tPos, "red");
		}

		if (hover && this.field.fieldMap[pos] != null) {
			tPos = playerOne? pos: (this.field.maxRow * this.field.maxCol - 1 - pos);
			var color = (playerOne == (this.field.fieldMap[pos].player == this.playerList[0]))? "blue": "red";
			
			if (!Array.from(ret.keys()).includes(tPos)) {
				ret.set(tPos, color);
			}
			
			for (var d of this.field.fieldMap[pos].getControlArea(this.field, pos)) {
				// Special rule for Duke
				if (this.field.fieldMap[pos].player == this.currentPlayer) {
					var isSafeD = true;
					for (var a of this.field.fieldMap[pos].getAvailableActions(this.field, pos)) {
						switch (a){
							case ActionType.MOVE:
								if (!this.isDukeSaveAfterAction(this.field, pos, this.field.fieldMap[pos].player, a, d)) {
									isSafeD = false;
								}
								break;
						}

						if (isSafeD == false) break;
					}

					if (isSafeD == false) continue;
				}

				tPos = playerOne? d: (this.field.maxRow * this.field.maxCol - 1 - d);
				ret.set(tPos, color);
			}
		}
			
		return ret;
	}
	
	isDukeSaveAfterAction(field, chessPos, player, action, opPos, commandPos = null) {
		var imagined_field = new Field(field.maxRow, field.maxCol);
		for (var i = 0; i < field.maxRow * field.maxCol; i++) {
			if (field.fieldMap[i] != null) {
				imagined_field.fieldMap[i] = imagined_field.chessFactory.createChess(field.fieldMap[i].chessType, field.fieldMap[i].player);
				imagined_field.fieldMap[i].starter = field.fieldMap[i].starter;
			}
		}

		switch (action) {
		case ActionType.MOVE:
			if (imagined_field.fieldMap[chessPos].getAvailableMovements(imagined_field, chessPos, action).get(opPos) == MovementType.STRIKE) {
				imagined_field.fieldMap[opPos] = null;

				imagined_field.fieldMap[chessPos].starter = !imagined_field.fieldMap[chessPos].starter;
			} else {
				imagined_field.fieldMap[opPos] = imagined_field.fieldMap[chessPos];
				imagined_field.fieldMap[chessPos] = null;

				imagined_field.fieldMap[opPos].starter = !imagined_field.fieldMap[opPos].starter;
			}

			var isDukeUnderControl = false;
			var foundEnemyDuke = false;
			for (var nn = 0; nn < field.maxRow * field.maxCol; nn++) {
				if (imagined_field.fieldMap[nn] != null && imagined_field.fieldMap[nn].chessType == ChessType.DUKE) {
					if (imagined_field.fieldMap[nn].player == player) {
						if (this.getControlAreaOfPlayer(imagined_field, (player == this.playerList[0])? this.playerList[1]: this.playerList[0]).includes(nn) &&
							!this.hasEnemyDuke(nn, player)) {
							isDukeUnderControl = true;
						} 
					} else {
						foundEnemyDuke = true;
					}
				}
			}

			if (foundEnemyDuke && isDukeUnderControl) {
				return false;
			}
			break;
		case ActionType.COMMAND:
			imagined_field.fieldMap[opPos] = imagined_field.fieldMap[commandPos];
			imagined_field.fieldMap[chessPos] = null;

			imagined_field.fieldMap[opPos].starter = !imagined_field.fieldMap[opPos].starter;

			var isDukeUnderControl = false;
			var foundEnemyDuke = false;
			for (var nn = 0; nn < field.maxRow * field.maxCol; nn++) {
				if (imagined_field.fieldMap[nn] != null && imagined_field.fieldMap[nn].chessType == ChessType.DUKE) {
					if (imagined_field.fieldMap[nn].player == player) {
						if (this.getControlAreaOfPlayer(imagined_field, (player == this.playerList[0])? this.playerList[1]: this.playerList[0]).includes(nn) &&
							!this.hasEnemyDuke(nn, player)) {
							isDukeUnderControl = true;
						} 
					} else {
						foundEnemyDuke = true;
					}
				}
			}

			if (foundEnemyDuke && isDukeUnderControl) {
				return false;
			}
			break;
		}
		return true;
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
		case GameState.CHOOSEDESTTWO:
			if (this.currentAction == ActionType.SUMMON) {
				ret = ret.concat("Confirm");
				ret = ret.concat("Cancel");
			}
		}
		
		return ret;
	}
	
	getMessage(playerOne) {
		var ret = "";
		
		switch (this.currentState) {
		case GameState.INITIALIZATION:
			ret = "Game started.";
			break;
		case GameState.INITSUMMONPLAYERONEFOOTMANONE:
			ret = playerOne? "Please summon your first footman." : "Waiting another player to summon footmen.";
			break;
		case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
			ret = playerOne? "Please summon your second footman." : "Waiting another player to summon footmen.";
			break;
		case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
			ret = !playerOne? "Please summon your first footman." : "Waiting another player to summon footmen.";
			break;
		case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
			ret = !playerOne? "Please summon your second footman." : "Waiting another player to summon footmen.";
			break;
		case GameState.CHOOSECHESS:
			ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a chess to perform action." : "Waiting another player to perform action.";
			break;
		case GameState.CHOOSEACTION:
			ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose an action." : "Waiting another player to perform action.";
			break;
		case GameState.CHOOSEDESTONE:
			switch (this.currentAction) {
			case ActionType.SUMMON:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? ("You are now summoning " + this.summonChess + ".") : "Waiting another player to perform action.";
				break;
			case ActionType.MOVE:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a place to perform move action." : "Waiting another player to perform action.";
				break;
			case ActionType.COMMAND:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a chess to command." : "Waiting another player to perform action.";
				break;
			}
			break;
		case GameState.CHOOSEDESTTWO:
			switch (this.currentAction) {
			case ActionType.SUMMON:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please comfirm your summon action." : "Waiting another player to perform action.";
				break;
			case ActionType.COMMAND:
				ret = (playerOne == (this.currentPlayer == this.playerList[0]))? "Please choose a destination for command action." : "Waiting another player to perform action.";
				break;
			}
			break;
		case GameState.ENDSTATE:
			ret = !this.checkPlayerLoss(playerOne)? "You win!": "You lose..."
			break;
		}
		
		return ret;
	}
	
	hasAvailableMovement(player, field) {
		// iterate all possible chess
		for(var i = 0; i < field.maxRow * field.maxCol; i++) {
			if (field.fieldMap[i] != null && field.fieldMap[i].player == player) {
				if (field.fieldMap[i].getAvailableActions(field, i).length > 0) {
					// iterate all possible actions
					for (var a of field.fieldMap[i].getAvailableActions(field, i)) {
						switch (a) {
							case ActionType.SUMMON:
								var possible_destinations = [...field.fieldMap[i].getAvailableMovements(field, i, ActionType.SUMMON).keys()];

								if (possible_destinations.length > 0) return true;

								break;

							case ActionType.MOVE:
								var movements = field.fieldMap[i].getAvailableMovements(field, i, ActionType.MOVE);
								for (var d in movements) {
									// Special rule for Duke
									if (this.isDukeSaveAfterAction(field, i, player, ActionType.MOVE, d)) {
										return true;
									}
								}
							
								break;
							
							case ActionType.COMMAND:
								for (var commandD in field.fieldMap[i].getAvailableMovements(field, i, ActionType.COMMAND)) {
									if (field.fieldMap[commandD] != null && field.fieldMap[commandD].player == player) {
										for (var targetD in field.fieldMap[i].getAvailableDests(field, i, ActionType.COMMAND)) {
											if (targetD != commandD && 
												((field.fieldMap[targetD] != null && field.fieldMap[targetD].player != player) || field.fieldMap[targetD] == null)) {
												// Special rule for Duke
												if (this.isDukeSaveAfterAction(field, i, player, ActionType.COMMAND, targetD, commandD)) {
													return true;
												}
											}
										}
									}
								}
								break;
						}
					}
				}
			}
		}
		return false;
	}

	getCurrentPlayer() {
		return (this.playerList[0] == this.currentPlayer)? 0: 1;
	}

	getWaitingMenu() {
		return this.waitingMenu;
	}

	getPreviousState() {
		return this.cachedState;
	}

	getCurrentState() {
		return this.currentState;
	}

	getTransformedUserOp(userOp) {
		return this.field.maxRow * this.field.maxCol - 1 - userOp;
	}

	getSummonChess() {
		return this.summonChess;
	}

	getAction() {
		return this.currentAction;
	}
}

module.exports = Game;