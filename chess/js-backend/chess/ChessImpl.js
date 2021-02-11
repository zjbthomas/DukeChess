const ActionType = require("./ActionType").ActionType;
const MovementType = require("../movement/MovementType").MovementType;
const ChessType = require("./ChessType").ChessType;

class ChessImpl {
    constructor(p, type, chessList) {
        this.player = p;
        this.chessType = type;
        this.actions = [];

		// for King and Rook
		this.castling = true;

		// for Pawn
		this.firstMove = true;
		this.capture = null;

        for (var chess of chessList) {
            if (chess.attr.name == type) {
                this.chessRoot = chess;

                var actionList = this.chessRoot.childNamed("actions").childrenNamed("action");
                for (var action of actionList) {
                    this.actions.push(action.val);
                }
                break;
            }
        }
    }

    getStyle(action) {
		var styleList = this.chessRoot.childNamed("styles").childrenNamed("style");
		var ret = new Map();
		for (var style of styleList) {
			if (style.childNamed("action").val == action) {
				var targetList = style.childNamed("targets").childrenNamed("target");
				for (var target of targetList) {
					ret.set(target.childNamed("destination").val, target.childNamed("movement").val);
				}
				return ret;
			}
		}
		return new Map();
	}
	
	getAvailableActions(field, pos) {
		var ret = [];
		for (var action of this.actions) {
			var dest = this.getAvailableDests(field, pos, action);
			if (0 == dest.length) continue;
				
			ret = ret.concat(action);
			}
		return ret;
	}
	

	getAvailableDests(field, pos, action) {
		var ret = [];
		for (var [d, m] of this.getStyle(action)) {
			var dest = field.movementFactory.createMovement(m).validateMovement(field, pos, d, this.player);
			ret= ret.concat(dest);			
		}
		return ret;
	}	
	
	getAvailableMovements(field, pos, action) {
		var ret = new Map();
		for (var [d, m] of this.getStyle(action)) {
			var dest = field.movementFactory.createMovement(m).validateMovement(field, pos, d, this.player);
			for (var dd of dest) {
				ret.set(dd, m);
			}
		}
		return ret;
	}
	
	getControlArea(field, pos) {
		var ret = [];
		for (var d of this.getAvailableDests(field, pos, ActionType.MOVE)) {
			if (!ret.includes(d)) ret = ret.concat(d);	
		}
		return ret;
	}

	getControlAreaPawn(field, pos, pp) {
		var ret = [];

		if (pp) {
			for (var d of this.getAvailableDests(field, pos, ActionType.MOVE)) {
				if (!ret.includes(d)) ret = ret.concat(d);	
			}
		} else {
			for (var [d, m] of this.getStyle(ActionType.MOVE)) {
				if (m == MovementType.CAPTURE) {
					var dest = field.movementFactory.createMovement(MovementType.CAPTUREATTEMPT).validateMovement(field, pos, d, this.player);
					for (var dd of dest) {
						if (!ret.includes(dd)) ret = ret.concat(dd);	
					}
				}
			}
		}

		

		return ret;
	}
    
	performAction(field, action, dest){
		switch (action) {
		case ActionType.MOVE:
			// cancel castling for King and Rook
			if (this.chessType == ChessType.KING || this.chessType == ChessType.ROOK) {
				this.castling = false;
			}

			// extra operations for Pawn
			if (this.chessType == ChessType.PAWN) {
				switch (this.getAvailableMovements(field, dest[0], action).get(dest[1])) {
					case MovementType.FIRSTMOVE:
						// update capture state of nearby chess
						for (var i = -1; i <= 1; i += 2) {
							// border detection
							if ((dest[1] % field.maxCol == 0 && i == -1) || (dest[1] % field.maxCol == field.maxCol - 1 && i == 1)) continue;
							
							if (field.fieldMap[dest[1] + i] != null &&
								field.fieldMap[dest[1] + i].player != this.player &&
								field.fieldMap[dest[1] + i].chessType == ChessType.PAWN) {
								field.fieldMap[dest[1] + i].capture = dest[1] + this.player.direction * -1 * field.maxCol;
							}
						}
						break;
					case MovementType.CAPTURE:
						if (this.capture != null) {
							field.fieldMap[dest[1] + this.player.direction * -1 * field.maxCol] = null;
							this.capture = null;
						}
						break;
				}

				// no metter what action, cancel first move (do it at the end as get AvailableMovements depends on this setting)
				this.firstMove = false;
			}

			// perform actual movement in the end
			field.fieldMap[dest[1]] = field.fieldMap[dest[0]];
			field.fieldMap[dest[0]] = null;

			// return new position for Pawns, for promotion checking
			if (this.chessType == ChessType.PAWN) {
				return dest[1];
			}

			break;

		case ActionType.CASTLING:
			var temp = field.fieldMap[dest[1]];
			field.fieldMap[dest[1]] = field.fieldMap[dest[0]];
			field.fieldMap[dest[0]] = temp;

			// cancel castling
			field.fieldMap[dest[0]].castling = false;
			field.fieldMap[dest[1]].castling = false;

			break;
		
		}
		return null;
	}
}

module.exports = ChessImpl;