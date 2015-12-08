package com.dexaint.dukechess.movement;

import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public interface Movement {
	public int[] validateMovement(Field currentField, int pos, Destination dest, Player p);
}
