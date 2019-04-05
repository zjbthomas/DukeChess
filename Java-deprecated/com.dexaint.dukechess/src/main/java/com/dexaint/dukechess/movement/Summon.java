package com.dexaint.dukechess.movement;

import org.apache.commons.lang3.ArrayUtils;

import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class Summon extends MovementImpl {
	public int[] validateMovement(Field field, int pos, Destination d, Player p) {
		int[] ret = new int[]{};
		
		int[] offsets = d.dest2Offset(p);
		
		if (0 != offsets[0] & 0 != offsets[1] & Math.abs(offsets[0]) != Math.abs(offsets[1])) return ret;
		
		if (!(1 == Math.abs(offsets[0]) || 1 == Math.abs(offsets[1]))) return ret;
		
		if (!isInField(field, pos, offsets) || hasAnyChess(field, pos, offsets)) return ret;
		
		ret = ArrayUtils.add(ret, offset2Dest(field, pos, d.dest2Offset(p)));
		
		return ret;
	}
}
