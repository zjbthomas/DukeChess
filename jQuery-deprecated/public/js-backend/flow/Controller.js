const Game = require("./Game");

class Controller {
    constructor(first, second, socket) {
        this.firstPoint = first;
        this.secondPoint = second;
        this.socket = socket;
    
        this.game = new Game(6, 6);
    
        this.point2Player = new Map();
        var randPlayer = Math.floor(Math.random() * 2);
        this.point2Player.set(first, randPlayer);
        this.point2Player.set(second, (0 == randPlayer)? 1: 0);

        this.init();
    }

    send(point, map) {
        var json = {};
        for (var [k, v] of map) {
            json[k] = v;
        }

        if (this.socket.id == point) {
            this.socket.emit("game", json);
        } else {
            this.socket.to(point).emit("game", json);
        }
    }

    init() {
        this.game.init();
		
        // Event point chess output
        var out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
		out.set("type", "chess");
		for (var [i, s] of this.game.getChessMap(this.point2Player.get(this.firstPoint) == 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
        }
        this.send(this.firstPoint, out);

		// Event point color output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
		out.set("type", "color");
		for (var [i, s] of this.game.getColorMap(this.point2Player.get(this.firstPoint) == 0, false, 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}
        this.send(this.firstPoint, out);
        
		// Peer point chess output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
		out.set("type", "chess");
		for (var [i, s] of this.game.getChessMap(this.point2Player.get(this.secondPoint) == 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}
        this.send(this.secondPoint, out);
        
		// Peer point color output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
		out.set("type", "color");
		for (var [i, s] of this.game.getColorMap(this.point2Player.get(this.secondPoint) == 0, false, 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}
		this.send(this.secondPoint, out);
	}
	
	execute(eventPoint, inMsg) {
		var peerPoint = (eventPoint == this.firstPoint)?this.secondPoint: this.firstPoint;
		
		var type = inMsg.type;
        
        var out = null;

		switch (type) {
		case "grid_click":
			// Check player
			if (this.game.getCurrentPlayer() != this.point2Player.get(eventPoint)) return;
			// Check waitingMenu
			if (this.game.waitingMenu) return;
			// Read Input
			var grid_click = inMsg.grid;
			var id = parseInt(grid_click.substring("grid_".length));
			// Perform
			if (this.game.performState(id)) {
				// Event point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
				out.set("type", "chess");
				for (var [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(eventPoint, out);
				
				// Peer point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
				out.set("type", "chess");
				for (var [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(peerPoint, out);

				// Game over Output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.checkPlayerWin(true)? "Player One Win.": "Player Two Win.");
				this.send(eventPoint, out);
				this.send(peerPoint, out);
				return;
			}
			// Event point chess output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "chess");
			for (var [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point menu output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "menu");
			out.set("menus", this.game.getMenu());
            this.send(eventPoint, out);
            
			// Peer point chess output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "chess");
			for (var [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);
            
			// Peer point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(peerPoint) == 0, false, 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);

			break;
		case "menu_click":
			// Check player
			if (this.game.getCurrentPlayer() != this.point2Player.get(eventPoint)) return;
			// Check waitingMenu
			if (!this.game.waitingMenu) return;
			// Read Input
            var menuClicked = inMsg.value;
            var userOp = 0;
			switch(menuClicked) {
			case "Summon": userOp = 1; break;
			case "Move": userOp = 2; break;
			case "Command": userOp = 3; break;
			case "Confirm": userOp = 1; break;
			case "Cancel": userOp = 0; break;
			default: userOp = 0; break;
			}
			// Perform
			if (this.game.performState(userOp)) {
				// Event point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
				out.set("type", "chess");
				for (var [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(eventPoint, out);
				
				// Peer point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
				out.set("type", "chess");
				for (var [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(peerPoint, out);

				// Game over Output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.checkPlayerWin(true)? "Player One Win.": "Player Two Win.");
				this.send(eventPoint, out);
				this.send(peerPoint, out);
				return;
			}
			// Event point chess output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "chess");
			for (var [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point menu output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "menu");
			out.set("menus", this.game.getMenu());
            this.send(eventPoint, out);
            
			// Peer point chess output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "chess");
			for (var [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);
            
			// Peer point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(peerPoint) == 0, false, 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);

			break;
		case "grid_hover":
			// Read Input
			var grid_hover = inMsg.grid;
			var id = parseInt(grid_hover.substring("grid_".length));
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, true, id)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);

			break;
        case "hover_restore":
        default:
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (var [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				var grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);

			break;
		}
	}
}

module.exports = Controller;