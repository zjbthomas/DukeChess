package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Bowman extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.U, MovementType.Move);
		frontMoveStyle.put(Destination.R, MovementType.Move);
		frontMoveStyle.put(Destination.L, MovementType.Move);
		frontMoveStyle.put(Destination.DD, MovementType.Jump);
		frontMoveStyle.put(Destination.RR, MovementType.Jump);
		frontMoveStyle.put(Destination.LL, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.DR, MovementType.Move);
		backMoveStyle.put(Destination.DL, MovementType.Move);
		backMoveStyle.put(Destination.UU, MovementType.Strike);
		backMoveStyle.put(Destination.UR, MovementType.Strike);
		backMoveStyle.put(Destination.UL, MovementType.Strike);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Bowman(Player player) {
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
