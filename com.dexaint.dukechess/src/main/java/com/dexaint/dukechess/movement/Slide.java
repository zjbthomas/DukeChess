package com.dexaint.dukechess.movement;

import org.apache.commons.lang3.ArrayUtils;

import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class Slide extends MovementImpl {

	public int[] validateMovement(Field field, int pos, Destination d, Player p) {
		int[] ret = new int[]{};
		
		int[] offsets = d.dest2Offset(p);
		
		if (0 != offsets[0] & 0 != offsets[1] & Math.abs(offsets[0]) != Math.abs(offsets[1])) return ret;
		
		if (1 < Math.abs(offsets[0]) || 1 < Math.abs(offsets[1])) return ret;
		
		int[] moveStep = getStep(offsets);

		int[] temp = {0, 0};
		temp[0] += moveStep[0];
		temp[1] += moveStep[1];
		
		while (isInField(field, pos, temp))
		{
			if (hasMyChess(field, pos, temp, p)) 
			{
				return ret;
			}
			else if(hasNotMyChess(field, pos, temp, p))
			{
				ret = ArrayUtils.add(ret, offset2Dest(field, pos, temp));
				return ret;
			}
			else 
			{
				ret = ArrayUtils.add(ret, offset2Dest(field, pos, temp));
			}
			
			temp[0] += moveStep[0];
			temp[1] += moveStep[1];
		}
		return ret;
	}
}
