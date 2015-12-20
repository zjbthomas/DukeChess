package com.dexaint.dukechess.chess;

import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;
import org.apache.commons.lang3.ArrayUtils;
import org.dom4j.Document;
import org.dom4j.Element;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class ChessImpl implements Chess{
	public boolean starter = true;
	private Player player;
	private ChessType chessType;
	private Element chessRoot;
	private ActionType[] actions;
	
	@SuppressWarnings("unchecked")
	protected ChessImpl(Player player, ChessType chessType, Document document) {
		this.player = player;
		this.chessType = chessType;

		List<Element> nameList = document.getRootElement().elements("name");
		for (Element name : nameList) {
			if (name.getText().equals(chessType.toString())) {
				this.chessRoot = name.getParent(); // Back to <chess/>
				this.actions = (ActionType[]) this.chessRoot.element("actions").elements("action").toArray();
				break;
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	public HashMap<Destination, MovementType> getStyle(ActionType action) {
		List<Element> styleList = this.chessRoot.element("styles").elements("style");
		HashMap<Destination, MovementType> ret = new HashMap<Destination, MovementType>();
		for (Element style : styleList) {
			if (style.element("action").getText().equals(action.toString()) &&
					(this.starter?"1":"0").equals(style.element("starter").getText())) {
				List<Element> targetList = style.element("targets").elements("target");
				for (Element target : targetList) {
					ret.put(Destination.valueOf(target.element("destination").getText()),
						MovementType.valueOf(target.element("movement").getText()));
				}
				return ret;
			}
		}
		return new HashMap<Destination, MovementType>();
	}
	
	public ActionType[] getAvailableActions(Field field, int pos) {
		ActionType[] ret = new ActionType[]{};
		for (ActionType action : actions) {
			int[] dest = getAvailableDests(field, pos, action);
			if (0 == dest.length) continue;
				
			ret = (ActionType[]) ArrayUtils.add(ret, action);
			}
		return ret;
	}
	

	public int[] getAvailableDests(Field field, int pos, ActionType action) {
		int[] ret = new int[]{};
		for (Entry<Destination, MovementType> kvp : getStyle(action).entrySet()) {
			int[] dest = field.getMovementFactory().createMovement(kvp.getValue()).validateMovement(field, pos, kvp.getKey(), player);
			ret= ArrayUtils.addAll(ret,dest);			
		}
		return ret;
	}	
	
	//public abstract HashMap<Destination, MovementType> getStyle(ActionType action);
	
	public Player getPlayer()
	{
		return player;
	}
}
