package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public interface Chess {
	ActionType[] getAvailableActions(Field field, int pos);
	HashMap<Destination, MovementType> getStyle(ActionType action);
	void performAction(Field field, ActionType action, int[] dest, Object...objs);
	int[] getAvailableDests(Field field, int pos, ActionType action);
	HashMap<Integer, MovementType> getAvailableMovements(Field field, int pos, ActionType action);
	int[] getControlArea(Field field, int pos);
	
	Player getPlayer();
	ChessType getChessType();
	public boolean getStarter();
}