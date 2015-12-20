package com.dexaint.dukechess.movement;

import org.apache.commons.lang3.ArrayUtils;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class Strike extends MovementImpl {
	public int[] validateMovement(Field field, int pos, Destination d, Player p) {
		int[] ret = new int[]{};
		
		int[] offsets = d.dest2Offset(p);
		
		if (!isInField(field, pos, offsets) || hasMyChess(field, pos, offsets, p)) return ret; // Short-Circuit-OR
		
		ret = ArrayUtils.add(ret, offset2Dest(field, pos, offsets));
		
		return ret;
	}
}
