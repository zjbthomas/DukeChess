package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public interface Chess {
	ActionType[] getAvailableActions(Field field, int pos);
	HashMap<Destination, MovementType> getStyle(ActionType action);
	Player getPlayer();
}