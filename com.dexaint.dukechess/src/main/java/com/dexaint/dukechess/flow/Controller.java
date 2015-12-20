package com.dexaint.dukechess.flow;

import java.util.HashMap;
import java.util.Random;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.app.App;
import com.dexaint.dukechess.web.PageBuilder;
import com.dexaint.dukechess.web.ServletStreamInbound;

public class Controller implements App {
	private ServletStreamInbound firstPoint;
	private ServletStreamInbound secondPoint;
	private Game game;
	private HashMap<ServletStreamInbound,Integer> point2Player = new HashMap<>();
	
	private int lastId;
	
	public Controller(ServletStreamInbound first, ServletStreamInbound second) {
		this.firstPoint = first;
		this.secondPoint = second;
		
		int randPlayer = new Random().nextInt(2);
		point2Player.put(first, randPlayer);
		point2Player.put(second, (0 == randPlayer)?1:0);
		
		game = new Game(PageBuilder.getBuilder().getMaxRow(),PageBuilder.getBuilder().getMaxCol());
	}
	
	public void execute(ServletStreamInbound eventPoint, HashMap<Object, Object> inMsg) {
		ServletStreamInbound peerPoint = (eventPoint == this.firstPoint)?this.secondPoint:this.firstPoint;
		
		String type = (String) inMsg.get("type");
		
		HashMap<Object, Object> out;
		
		//game.NextStep(userOp);
		
		switch (type) {
		case "grid_click":
			// Read Input
			String grid_click = (String) inMsg.get("grid");
			this.lastId = Integer.parseInt(grid_click.substring("grid_".length()));
			// Create Output
			out = new HashMap<>();
			out.put("connection", "true");
			out.put("message", "Menu showed.");
			out.put("type", type);
			ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
			out.put("actions",actions);
			//Send Output
			eventPoint.send(out);
			break;
		case "menu_click":
			// Read Input
			String button = (String) inMsg.get("value");
			// Create Output:
			out = new HashMap<>();
			out.put("connection", "true");
			out.put("message", "Menu clicked.");
			out.put("type", type);
			out.put("grid_"+this.lastId,"dummy");
			// Send Output
			eventPoint.send(out);
			// Create Output
			out = new HashMap<>();
			out.put("connection", "true");
			out.put("message", "New update.");
			out.put("type", type);
			out.put("grid_"+this.lastId,"dummy");
			// Send Output
			peerPoint.send(out);
			break;
		case "grid_hover":
			// Read Input
			String grid_hover = (String) inMsg.get("grid");
			int grid_hover_id = Integer.parseInt(grid_hover.substring("grid_".length()));
			// Create Output
			out = new HashMap<>();
			out.put("connection", "true");
			out.put("message", "Hover.");
			out.put("type", type);
			out.put("grid_"+grid_hover_id,"dummy");
			//Send Output
			eventPoint.send(out);
			break;
		}
	}
}
