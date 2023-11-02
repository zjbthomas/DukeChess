const Game = require("./Game");

class Controller {
    constructor(first, firstPointPlatform, second, secondPointPlatform, socket) {
        this.firstPoint = first;
		this.firstPlatform = firstPointPlatform;

        this.secondPoint = second;
		this.secondPlatform = secondPointPlatform;

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

	browserDefaultOutput(point) {
		// Chess output
		var out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(point) == 0));
		out.set("type", "chess");
		for (var [i, s] of this.game.getChessMap(this.point2Player.get(point) == 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}
		this.send(point, out);

		// Color output
		out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(point) == 0));
		out.set("type", "color");
		for (var [i, s] of this.game.getColorMap(this.point2Player.get(point) == 0, false, 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}
		this.send(point, out);

	}

	unityDefaultOutput(op, point, needTransform) {
		var out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(point) == 0));
		out.set("type", "game");
		// Confirm previous state op
		out.set("state", this.game.getPreviousState());
		out.set("userop", needTransform? this.game.getTransformedUserOp(op): op);
		out.set("action", this.game.getAction());
		out.set("summon", this.game.getSummonChess());
		
		// Always store color
		for (var [i, s] of this.game.getColorMap(this.point2Player.get(point) == 0, false, 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}

		// Show current state op
		if (this.point2Player.get(point) == this.game.getCurrentPlayer()) {
			out.set("active", "true");
	
			if (this.game.getWaitingMenu()) {
				out.set("menus", this.game.getMenu());
			}
		} else {
			out.set("active", "false");
		}
		if (this.game.getWaitingMenu()) {
			out.set("subtype", "inmenu");
		} else {
			out.set("subtype", "nomenu");
		}
		
		this.send(point, out);
	}

	unityDefaultOutput(op, point, needTransform) {
		var out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(point) == 0));
		out.set("type", "game");
		// Confirm previous state op
		out.set("state", this.game.getPreviousState());
		out.set("userop", needTransform? this.game.getTransformedUserOp(op): op);
		out.set("action", this.game.getAction());
		out.set("summon", this.game.getSummonChess());
		
		// Always store color
		for (var [i, s] of this.game.getColorMap(this.point2Player.get(point) == 0, false, 0)) {
			var grid = "grid_" + i;
			out.set(grid, s);
		}

		// Show current state op
		if (this.point2Player.get(point) == this.game.getCurrentPlayer()) {
			out.set("active", "true");
	
			if (this.game.getWaitingMenu()) {
				out.set("menus", this.game.getMenu());
			}
		} else {
			out.set("active", "false");
		}
		if (this.game.getWaitingMenu()) {
			out.set("subtype", "inmenu");
		} else {
			out.set("subtype", "nomenu");
		}
		
		this.send(point, out);
	}

	unityGameoverOutput(op, point, needTransform) {
		var out = new Map();
		out.set("connection", "true");
		out.set("message", this.game.getMessage(this.point2Player.get(point) == 0));
		out.set("type", "gameover");
		// Confirm previous state op
		out.set("state", this.game.getPreviousState());
		out.set("userop", needTransform? this.game.getTransformedUserOp(op): op);
		out.set("action", this.game.getAction());
		out.set("summon", this.game.getSummonChess());
		
		// No need to store color; reset all colors at client side

		// No animation and no menu
		out.set("active", "false");
		out.set("subtype", "nomenu");
	
		this.send(point, out);
	}

    init() {
		// For Unity, send an initialization signal
		if (this.firstPlatform.localeCompare("unity") == 0) {
			var out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
			out.set("type", "init");
			out.set("firstplayer", (this.point2Player.get(this.firstPoint) == 0)? "true": "false");
			this.send(this.firstPoint, out);
		}
		if (this.secondPlatform.localeCompare("unity") == 0) {
			var out = new Map();
			out.set("connection", "true");
			out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
			out.set("type", "init");
			out.set("firstplayer", (this.point2Player.get(this.secondPoint) == 0)? "true": "false");
			this.send(this.secondPoint, out);
		}

		// Initialize game
        this.game.init();
		
		// Event point output
		switch (this.firstPlatform) {
			case "browser":
				this.browserDefaultOutput(this.firstPoint);
				break;
			case "unity":
				var out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(this.firstPoint) == 0));
				out.set("type", "color");
				for (var [i, s] of this.game.getColorMap(this.point2Player.get(this.firstPoint) == 0, false, 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
				}
				this.send(this.firstPoint, out);

				break;
		}
        
		// Peer point output
		switch (this.secondPlatform) {
			case "browser":
				this.browserDefaultOutput(this.secondPoint);
				break;
			case "unity":
				var out = new Map();
				out.set("connection", "true");
				out.set("message", this.game.getMessage(this.point2Player.get(this.secondPoint) == 0));
				out.set("type", "color");
				for (var [i, s] of this.game.getColorMap(this.point2Player.get(this.secondPoint) == 0, false, 0)) {
					var grid = "grid_" + i;
					out.set(grid, s);
				}
				this.send(this.secondPoint, out);

				break;
		}
	}
	
	performOp(isMenu, op, eventPoint, peerPoint, eventPointPlatform, peerPointPlatform) {
		var out = null;

		if (this.game.performState(op)) {
			if (this.game.checkPlayerWin(true) || this.game.checkPlayerWin(false)) {
				// Gameover
				var end_out = new Map();
				end_out.set("connection", "true");
				end_out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));

				switch (eventPointPlatform) {
					case "browser":
						// Chess output
						out = new Map();
						out.set("connection", "true");
						out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
						out.set("type", "chess");
						for (var [i, s] of this.game.getChessMap(this.point2Player.get(eventPoint) == 0)) {
							var grid = "grid_" + i;
							out.set(grid, s);
						}
						this.send(eventPoint, out);

						// Game over Output
						this.send(eventPoint, end_out);

						break;
					case "unity":
						this.unityGameoverOutput(op, eventPoint, false)
						break;
				}

				switch (peerPointPlatform) {
					case "browser":
						// Chess output
						out = new Map();
						out.set("connection", "true");
						out.set("message", this.game.getMessage(this.point2Player.get(peerPoint) == 0));
						out.set("type", "chess");
						for (var [i, s] of this.game.getChessMap(this.point2Player.get(peerPoint) == 0)) {
							var grid = "grid_" + i;
							out.set(grid, s);
						}
						this.send(peerPoint, out);

						// Gameover Output
						this.send(peerPoint, end_out);
						break;
					case "unity":
						this.unityGameoverOutput(op, peerPoint, !isMenu)
						break;
				}
			} else {
				// Not gameover
				switch (eventPointPlatform) {
					case "browser":
						this.browserDefaultOutput(eventPoint);

						// Menu output
						out = new Map();
						out.set("connection", "true");
						out.set("message", this.game.getMessage(this.point2Player.get(eventPoint) == 0));
						out.set("type", "menu");
						out.set("menus", this.game.getMenu());
						this.send(eventPoint, out);

						break;
					case "unity":
						this.unityDefaultOutput(op, eventPoint, false);

						break;
				}

				switch (peerPointPlatform) {
					case "browser":
						this.browserDefaultOutput(peerPoint);
						break;
					case "unity":
						this.unityDefaultOutput(op, peerPoint, !isMenu);
						break;
				}
			}
			
		}
	}

	execute(eventPoint, inMsg) {
		// Get peer
		var peerPoint = (eventPoint == this.firstPoint)?this.secondPoint: this.firstPoint;

		// Get platforms
		var eventPointPlatform = (eventPoint == this.firstPoint)?this.firstPlatform: this.secondPlatform;
		var peerPointPlatform = (peerPoint == this.firstPoint)?this.firstPlatform: this.secondPlatform;
		
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
			this.performOp(false, id, eventPoint, peerPoint, eventPointPlatform, peerPointPlatform);
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
			this.performOp(true, userOp, eventPoint, peerPoint, eventPointPlatform, peerPointPlatform);
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