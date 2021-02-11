package com.dexaint.dukechess.movement;

import java.util.Arrays;
import java.util.Collections;

import org.apache.commons.lang3.ArrayUtils;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class Jump extends MovementImpl {
	public int[] validateMovement(Field field, int pos, Destination d, Player p) {
		int[] ret = new int[]{};
		
		int[] offsets = d.dest2Offset(p);
		
		if (1 >= Math.abs(offsets[0]) & 1 >= Math.abs(offsets[1])) return ret;
		
		if (!isInField(field, pos, offsets) || hasMyChess(field, pos, offsets, p)) return ret; // Short-Circuit-OR
		
		ret = ArrayUtils.add(ret, offset2Dest(field, pos, offsets));
		
		return ret;
	}
}
