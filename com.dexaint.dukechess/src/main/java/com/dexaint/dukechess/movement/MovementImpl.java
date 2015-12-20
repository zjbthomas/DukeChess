package com.dexaint.dukechess.movement;

import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public abstract class MovementImpl implements Movement {
	protected int offset2Dest(Field field, int pos, int[] offsets) {
		return pos + offsets[0] * field.getMaxRow() + offsets[1];
	}
	
	protected boolean isInField(Field field, int pos, int[] offsets) {
		int[] posOffsets = pos2RowCol(field, pos);
		return (posOffsets[0] + offsets[0] >= 0) & (posOffsets[0] + offsets[0] < field.getMaxRow())
				& (posOffsets[1] + offsets[1] >= 0) & (posOffsets[1] + offsets[1] < field.getMaxCol());
	}
	
	protected boolean hasAnyChess(Field field, int pos, int[] offsets) {
		return (null!=field.getChess(offset2Dest(field, pos, offsets)));
	}
	
	protected boolean hasMyChess(Field field, int pos, int[] offsets, Player p) {
		return hasAnyChess(field, pos, offsets) && // Short-circuit-AND
				(field.getChess(offset2Dest(field, pos, offsets)).getPlayer().equals(p));
	}
	
	protected boolean hasNotMyChess(Field field, int pos, int[] offsets, Player p) {
		return hasAnyChess(field, pos, offsets) && // Short-circuit-AND
				!hasMyChess(field, pos, offsets, p);
	}
	
	protected int[] pos2RowCol(Field field, int pos) {
		int[] ret = new int[2];
		ret[0] = pos / field.getMaxCol();
		ret[1] = pos % field.getMaxCol();
		return ret;
	}
	
	protected int[] getStep(int[] offsets)
	{
		int[] step = {0, 0};
		if(offsets[0] > 0)
			step[0] = 1;
		else if(offsets[0] < 0)
			step[0] = -1;
		
		if(offsets[1] > 0)
			step[1] = 1;
		else if(offsets[1] < 0)
			step[1] = -1;
		return step;
	}
}
