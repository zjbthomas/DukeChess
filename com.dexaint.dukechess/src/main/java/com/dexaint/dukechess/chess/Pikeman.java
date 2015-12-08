package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Pikeman extends ChessImpl{
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.UR, MovementType.Move);
		frontMoveStyle.put(Destination.UL, MovementType.Move);
		frontMoveStyle.put(Destination.UURR, MovementType.Move);
		frontMoveStyle.put(Destination.UULL, MovementType.Move);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.UUR, MovementType.Strike);
		backMoveStyle.put(Destination.UUL, MovementType.Strike);
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.D, MovementType.Move);
		backMoveStyle.put(Destination.DD, MovementType.Move);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Pikeman(Player player) {
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
