"use strict";

const Game = require("./Game");

class Controller {
    constructor(first, second, emitter) {
        this.firstPoint = first;
        this.secondPoint = second;
        this.emitter = emitter;
    
        this.game = new Game(8, 8);
    
        this.point2Player = new Map();
        var randPlayer = Math.floor(Math.random() * 2);
        this.point2Player.set(first, randPlayer);
        this.point2Player.set(second, (0 == randPlayer)? 1: 0);

        this.init();
    }

    send(point, map) {
        const json = {};
        for (const [k, v] of map) json[k] = v;

        this.emitter.emitToSocket(point, "game", json);
    }

    init() {
        this.game.init();
		
        // Event point chess output
        let out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
		out.set("type", "chess");
		for (const [i, s] of this.game.getChessMap(this.point2Player.get(this.firstPoint) == 0)) {
			const grid = "grid_" + i;
			out.set(grid, s);
        }
        this.send(this.firstPoint, out);

		// Event point color output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
		out.set("type", "color");
		for (const [i, s] of this.game.getColorMap(this.point2Player.get(this.firstPoint) == 0, false, 0)) {
			const grid = "grid_" + i;
			out.set(grid, s);
		}
        this.send(this.firstPoint, out);
        
		// Peer point chess output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
		out.set("type", "chess");
		for (const [i, s] of this.game.getChessMap(this.point2Player.get(this.secondPoint) == 0)) {
			const grid = "grid_" + i;
			out.set(grid, s);
		}
        this.send(this.secondPoint, out);
        
		// Peer point color output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
		out.set("type", "color");
		for (const [i, s] of this.game.getColorMap(this.point2Player.get(this.secondPoint) == 0, false, 0)) {
			const grid = "grid_" + i;
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
				for (const [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
					const grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(eventPoint, out);
				
				// Peer point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
				out.set("type", "chess");
				for (const [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
					const grid = "grid_" + i;
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
			for (const [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				const grid = "grid_" + i;
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
			for (const [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);
            
			// Peer point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(peerPoint) == 0, false, 0)) {
				const grid = "grid_" + i;
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
				// actions
				case "Move": userOp = 1; break;
				case "Castling": userOp = 2; break;
				// promotion
				case "Rook": userOp = 1; break;
				case "Bishop": userOp = 2; break;
				case "Queen": userOp = 3; break;
				case "Knight": userOp = 4; break;
				// others
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
				for (const [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
					const grid = "grid_" + i;
					out.set(grid, s);
                }
                this.send(eventPoint, out);
				
				// Peer point chess output
				out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
				out.set("type", "chess");
				for (const [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
					const grid = "grid_" + i;
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
			for (const [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);
            
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				const grid = "grid_" + i;
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
			for (const [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);
            
			// Peer point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(peerPoint) == 0, false, 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(peerPoint, out);

			break;
		case "grid_hover": {
			// Read Input
			const grid_hover = inMsg.grid;
			let id = parseInt(grid_hover.substring("grid_".length));
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, true, id)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);

			break;
		}
        case "hover_restore":
        default:
			// Event point color output
			out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
			out.set("type", "color");
			for (const [i, s] of this.game.getColorMap(this.point2Player.get(eventPoint) == 0, false, 0)) {
				const grid = "grid_" + i;
				out.set(grid, s);
			}
            this.send(eventPoint, out);

			break;
		}
	}
}

module.exports = Controller;