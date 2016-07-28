package com.dexaint.dukechess.flow;

import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Random;

import com.dexaint.dukechess.app.App;
import com.dexaint.dukechess.chess.ActionType;
import com.dexaint.dukechess.movement.MovementType;
import com.dexaint.dukechess.web.PageBuilder;
import com.dexaint.dukechess.web.ServletStreamInbound;

public class Controller implements App {
	private ServletStreamInbound firstPoint;
	private ServletStreamInbound secondPoint;
	private Game game;
	private HashMap<ServletStreamInbound,Integer> point2Player = new HashMap<>();
	
	public Controller(ServletStreamInbound first, ServletStreamInbound second) {
		this.firstPoint = first;
		this.secondPoint = second;
		
		int randPlayer = new Random().nextInt(2);
		point2Player.put(first, randPlayer);
		point2Player.put(second, (0 == randPlayer)?1:0);
		
		game = new Game(PageBuilder.getBuilder().getMaxRow(),PageBuilder.getBuilder().getMaxCol());
		
		this.Initialization();
	}
	
	public void Initialization() {
		game.Initialization();
		
		HashMap<Object, Object> out;
		
		// Event point chess output
		out = new HashMap<Object, Object>();
		out.put("connection", "true");
		out.put("message", game.getMessage(point2Player.get(this.firstPoint) == 0));
		out.put("type", "chess");
		for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(this.firstPoint) == 0).entrySet()) {
			String grid = "grid_" + kvp.getKey();
			out.put(grid, kvp.getValue());
		}
		this.firstPoint.send(out);
		// Event point color output
		out = new HashMap<Object, Object>();
		out.put("connection", "true");
		out.put("message", game.getMessage(point2Player.get(this.firstPoint) == 0));
		out.put("type", "color");
		for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(this.firstPoint) == 0, false, 0).entrySet()) {
			String grid = "grid_" + kvp.getKey();
			out.put(grid, kvp.getValue());
		}
		this.firstPoint.send(out);
		// Peer point chess output
		out = new HashMap<Object, Object>();
		out.put("connection", "true");
		out.put("message", game.getMessage(point2Player.get(this.secondPoint) == 0));
		out.put("type", "chess");
		for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(this.secondPoint) == 0).entrySet()) {
			String grid = "grid_" + kvp.getKey();
			out.put(grid, kvp.getValue());
		}
		this.secondPoint.send(out);
		// Peer point color output
		out = new HashMap<Object, Object>();
		out.put("connection", "true");
		out.put("message", game.getMessage(point2Player.get(this.secondPoint) == 0));
		out.put("type", "color");
		for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(this.secondPoint) == 0, false, 0).entrySet()) {
			String grid = "grid_" + kvp.getKey();
			out.put(grid, kvp.getValue());
		}
		this.secondPoint.send(out);
	}
	
	public void execute(ServletStreamInbound eventPoint, HashMap<Object, Object> inMsg) {
		ServletStreamInbound peerPoint = (eventPoint == this.firstPoint)?this.secondPoint:this.firstPoint;
		
		String type = (String) inMsg.get("type");
		HashMap<Object, Object> out;
		
		int id;
		
		switch (type) {
		case "grid_click":
			// Check player
			if (game.getCurrentPlayer() != point2Player.get(eventPoint)) return;
			// Check waitingMenu
			if (game.getWaitingMenu()) return;
			// Read Input
			String grid_click = (String) inMsg.get("grid");
			id = Integer.parseInt(grid_click.substring("grid_".length()));
			// Perform
			if (game.performState(id)) {
				// Event point chess output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
				out.put("type", "chess");
				for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(eventPoint) == 0).entrySet()) {
					String grid = "grid_" + kvp.getKey();
					out.put(grid, kvp.getValue());
				}
				eventPoint.send(out);
				// Peer point chess output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
				out.put("type", "chess");
				for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(peerPoint) == 0).entrySet()) {
					String grid = "grid_" + kvp.getKey();
					out.put(grid, kvp.getValue());
				}
				peerPoint.send(out);
				// Game over Output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.checkPlayerWin(true)? "Player One Win": "Player Two Win");
				eventPoint.send(out);
				peerPoint.send(out);
				return;
			}
			// Event point chess output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "chess");
			for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(eventPoint) == 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			// Event point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(eventPoint) == 0, false, 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			// Event point menu output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "menu");
			out.put("menus", game.getMenu());
			eventPoint.send(out);
			// Peer point chess output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
			out.put("type", "chess");
			for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(peerPoint) == 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			peerPoint.send(out);
			// Peer point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(peerPoint) == 0, false, 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			peerPoint.send(out);
			break;
		case "menu_click":
			// Check player
			if (game.getCurrentPlayer() != point2Player.get(eventPoint)) return;
			// Check waitingMenu
			if (!game.getWaitingMenu()) return;
			// Read Input
			String menuClicked = (String) inMsg.get("value");
			int userOp;
			switch(menuClicked) {
			case "Summon": userOp = 1; break;
			case "Move": userOp = 2; break;
			case "Command": userOp = 3; break;
			case "Confirm": userOp = 1; break;
			case "Cancel": userOp = 0; break;
			default: userOp = 0; break;
			}
			// Perform
			if (game.performState(userOp)) {
				// Event point chess output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
				out.put("type", "chess");
				for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(eventPoint) == 0).entrySet()) {
					String grid = "grid_" + kvp.getKey();
					out.put(grid, kvp.getValue());
				}
				eventPoint.send(out);
				// Peer point chess output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
				out.put("type", "chess");
				for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(peerPoint) == 0).entrySet()) {
					String grid = "grid_" + kvp.getKey();
					out.put(grid, kvp.getValue());
				}
				peerPoint.send(out);
				// Game over Output
				out = new HashMap<Object, Object>();
				out.put("connection", "true");
				out.put("message", game.checkPlayerWin(true)? "Player One Win": "Player Two Win");
				eventPoint.send(out);
				peerPoint.send(out);
				return;
			}
			// Event point chess output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "chess");
			for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(eventPoint) == 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			// Event point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(eventPoint) == 0, false, 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			// Event point menu output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "menu");
			out.put("menus", game.getMenu());
			eventPoint.send(out);
			// Peer point chess output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
			out.put("type", "chess");
			for (Entry<Integer, String> kvp : game.getChessMap(point2Player.get(peerPoint) == 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			peerPoint.send(out);
			// Peer point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(peerPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(peerPoint) == 0, false, 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			peerPoint.send(out);
			break;
		case "grid_hover":
			// Read Input
			String grid_hover = (String) inMsg.get("grid");
			id = Integer.parseInt(grid_hover.substring("grid_".length()));
			// Event point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(eventPoint) == 0, true, id).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			break;
		case "hover_restore":
			// Event point color output
			out = new HashMap<Object, Object>();
			out.put("connection", "true");
			out.put("message", game.getMessage(point2Player.get(eventPoint) == 0));
			out.put("type", "color");
			for (Entry<Integer, String> kvp : game.getColorMap(point2Player.get(eventPoint) == 0, false, 0).entrySet()) {
				String grid = "grid_" + kvp.getKey();
				out.put(grid, kvp.getValue());
			}
			eventPoint.send(out);
			break;
		}
	}
}
