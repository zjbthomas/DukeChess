package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Ranger extends ChessImpl{
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.U, MovementType.Slide);
		frontMoveStyle.put(Destination.D, MovementType.Slide);
		frontMoveStyle.put(Destination.UUR, MovementType.Jump);
		frontMoveStyle.put(Destination.UUL, MovementType.Jump);
		frontMoveStyle.put(Destination.RRU, MovementType.Jump);
		frontMoveStyle.put(Destination.LLU, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.UR, MovementType.Slide);
		backMoveStyle.put(Destination.UL, MovementType.Slide);
		backMoveStyle.put(Destination.DDR, MovementType.Jump);
		backMoveStyle.put(Destination.DDL, MovementType.Jump);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Ranger(Player player) {
		super(player, actions);
	}
	
	public HashMap<Destination, MovementType> getStyle(ActionType action) {
		switch (action) {
			case Move:
				if (starter) {
					return frontMoveStyle;
				}
				else {
					return backMoveStyle;
				}
			default:
				return new HashMap<Destination, MovementType>();
		}
	}
}
