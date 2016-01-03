package com.dexaint.dukechess.chess;

import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;
import org.apache.commons.lang3.ArrayUtils;
import org.dom4j.Element;

import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class ChessImpl implements Chess{
	public boolean starter = true;
	private Player player;
	@SuppressWarnings("unused")
	private ChessType chessType;
	private Element chessRoot;
	private ActionType[] actions;
	
	@SuppressWarnings("unchecked")
	protected ChessImpl(Player player, ChessType chessType, List<Element> chessList) {
		this.player = player;
		this.chessType = chessType;

		for (Element chess : chessList) {
			if (chess.attribute("name").getText().equals(chessType.toString())) {
				this.chessRoot = chess;
				List<Element> actionList = this.chessRoot.element("actions").elements("action");
				for (Element action : actionList) {
					ArrayUtils.add(actions, ActionType.valueOf(action.getText()));
				}
				break;
			}
		}
	}
	
	@SuppressWarnings("unchecked")
	public HashMap<Destination, MovementType> getStyle(ActionType action) {
		List<Element> styleList = this.chessRoot.element("styles").elements("style");
		HashMap<Destination, MovementType> ret = new HashMap<Destination, MovementType>();
		for (Element style : styleList) {
			if (style.element("action").getText().equals(action.toString())) {
				if ((null == style.element("starter")) || (this.starter?"1":"0").equals(style.element("starter").getText())) {
					List<Element> targetList = style.element("targets").elements("target");
					for (Element target : targetList) {
						ret.put(Destination.valueOf(target.element("destination").getText()),
							MovementType.valueOf(target.element("movement").getText()));
					}
					return ret;
				}
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
	
	public void performAction(Field field, ActionType action, int[] dest, Object...objs){
		ChessType type = null;
		Player p = null;
		for (Object obj : objs) {
			if (obj.getClass().equals(ChessType.class)) {
				type = (ChessType) obj;
			}	
			if (obj.getClass().equals(Player.class)) {
				p = (Player) obj;
			}	
		}
		switch (action) {
		case Summon:
			field.setChess(field.getChessFactory().createChess(type, p), dest[0]);
			break;
		case Move:
		case Command:
			field.setChess(field.getChess(dest[0]), dest[1]);
			field.setChess(null, dest[0]);
			this.starter=!starter;
			break;
		}
	}
	
	//public abstract HashMap<Destination, MovementType> getStyle(ActionType action);
	
	public Player getPlayer()
	{
		return player;
	}
}
