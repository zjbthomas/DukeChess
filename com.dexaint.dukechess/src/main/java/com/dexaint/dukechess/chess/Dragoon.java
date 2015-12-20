package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Dragoon extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.R, MovementType.Move);
		frontMoveStyle.put(Destination.L, MovementType.Move);
		frontMoveStyle.put(Destination.UU, MovementType.Strike);
		frontMoveStyle.put(Destination.UURR, MovementType.Strike);
		frontMoveStyle.put(Destination.UULL, MovementType.Strike);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.UU, MovementType.Move);
		backMoveStyle.put(Destination.UUR, MovementType.Jump);
		backMoveStyle.put(Destination.UUL, MovementType.Jump);
		backMoveStyle.put(Destination.DR, MovementType.Slide);
		backMoveStyle.put(Destination.DL, MovementType.Slide);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Dragoon(Player player) {
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
