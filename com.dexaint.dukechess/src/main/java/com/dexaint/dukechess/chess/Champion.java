/*package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Champion extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.U, MovementType.Move);
		frontMoveStyle.put(Destination.D, MovementType.Move);
		frontMoveStyle.put(Destination.R, MovementType.Move);
		frontMoveStyle.put(Destination.L, MovementType.Move);
		frontMoveStyle.put(Destination.UU, MovementType.Jump);
		frontMoveStyle.put(Destination.DD, MovementType.Jump);
		frontMoveStyle.put(Destination.RR, MovementType.Jump);
		frontMoveStyle.put(Destination.LL, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Strike);
		backMoveStyle.put(Destination.D, MovementType.Strike);
		backMoveStyle.put(Destination.R, MovementType.Strike);
		backMoveStyle.put(Destination.L, MovementType.Strike);
		backMoveStyle.put(Destination.UU, MovementType.Jump);
		backMoveStyle.put(Destination.DD, MovementType.Jump);
		backMoveStyle.put(Destination.RR, MovementType.Jump);
		backMoveStyle.put(Destination.LL, MovementType.Jump);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Champion(Player player) {
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
*/