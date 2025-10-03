const ActionType = require("./ActionType").ActionType;
const MovementType = require("../movement/MovementType").MovementType;

class ChessImpl {
    constructor(p, type, chessList) {
        this.starter = true;
        this.player = p;
        this.chessType = type;
        this.actions = [];

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
				if ((null == style.childNamed("starter")) || (this.starter?"1":"0") == (style.childNamed("starter").val)) {
					var targetList = style.childNamed("targets").childrenNamed("target");
					for (var target of targetList) {
						ret.set(target.childNamed("destination").val, target.childNamed("movement").val);
					}
					return ret;
				}
			}
		}
		return new Map();
	}
	
	getAvailableActions(field, pos) {
		var ret = [];
		for (var action of this.actions) {
			if (action == ActionType.SUMMON) {
				if (!this.player.isSummonAvailable()) continue;
			}

			var dest = this.getAvailableDests(field, pos, action);
			if (0 == dest.length) continue;
				
			ret = ret.concat(action);
			}
		return ret;
	}
	
	getAvailableDests(field, pos, action) {
		return [...this.getAvailableMovements(field, pos, action).keys()];
	}	
	
	getAvailableMovements(field, pos, action) {
		var ret = new Map();

		if (action == ActionType.COMMAND) {
			var hasCommandableChess = false;
			for (var [d, m] of this.getStyle(action)) {
				if (field.movementFactory.createMovement(m).hasMyChess(field, pos, d, this.player)) {
					hasCommandableChess = true;
					break;
				}
			}

			if (!hasCommandableChess) return ret;
		}

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

		for (var [d, m] of this.getStyle(ActionType.MOVE)) {
			var dest = field.movementFactory.createMovement(m).validateControlArea(field, pos, d, this.player);
			for (var dd of dest) {
				if (!ret.includes(dd)) ret = ret.concat(dd);
			}
		}

		var hasCommandableChess = false;
		for (var [d, m] of this.getStyle(ActionType.COMMAND)) {
			if (field.movementFactory.createMovement(m).hasMyChess(field, pos, d, this.player)) {
				hasCommandableChess = true;
				break;
			}
		}

		if (hasCommandableChess) {
			for (var [d, m] of this.getStyle(ActionType.COMMAND)) {
				var dest = field.movementFactory.createMovement(m).validateControlArea(field, pos, d, this.player);
				for (var dd of dest) {
					if (!ret.includes(dd)) ret = ret.concat(dd);
				}
			}
		}

		return ret;
	}
    
	performAction(field, action, dest, type, p){
		switch (action) {
		case ActionType.SUMMON:
			field.fieldMap[dest[0]] = field.chessFactory.createChess(type, p);
			p.removeFromList(type);
			break;
		case ActionType.MOVE:
			if (this.getAvailableMovements(field, dest[0], action).get(dest[1]) == MovementType.STRIKE) {
				field.fieldMap[dest[1]] = null;
			} else {
				field.fieldMap[dest[1]] = field.fieldMap[dest[0]];
				field.fieldMap[dest[0]] = null;
			}
			this.starter = !this.starter;
			break;
		case ActionType.COMMAND:
			field.fieldMap[dest[1]] = field.fieldMap[dest[0]];
			field.fieldMap[dest[0]] = null;
			this.starter = !this.starter;
			break;
		}
	}
}

module.exports = ChessImpl;