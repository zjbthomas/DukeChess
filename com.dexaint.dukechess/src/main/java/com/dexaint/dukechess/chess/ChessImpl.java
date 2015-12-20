package com.dexaint.dukechess.chess;

import java.util.HashMap;
import java.util.Map.Entry;

import org.apache.commons.lang3.ArrayUtils;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public abstract class ChessImpl implements Chess{
	public boolean starter = true;
	private Player player;
	private ActionType[] actions;
	
	protected ChessImpl(Player player, ActionType[] actions) {
		this.player = player;
		this.actions = actions;
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
	
	public abstract HashMap<Destination, MovementType> getStyle(ActionType action);

	public void performAction(Field field, ActionType action, int[] dest, ChessType type, Player p) {
		switch (action) {
		case Move:
			
		case Summon:
			field.setChess(field.getChessFactory().createChess(type, p), dest[0]);;
		case Command:
			
		}
	}
	
	public Player getPlayer()
	{
		return player;
	}
}
