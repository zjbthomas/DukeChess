/*package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Seer extends ChessImpl{
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.UR, MovementType.Move);
		frontMoveStyle.put(Destination.UL, MovementType.Move);
		frontMoveStyle.put(Destination.DR, MovementType.Move);
		frontMoveStyle.put(Destination.DL, MovementType.Move);
		frontMoveStyle.put(Destination.UU, MovementType.Jump);
		frontMoveStyle.put(Destination.DD, MovementType.Jump);
		frontMoveStyle.put(Destination.RR, MovementType.Jump);
		frontMoveStyle.put(Destination.LL, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.D, MovementType.Move);
		backMoveStyle.put(Destination.R, MovementType.Move);
		backMoveStyle.put(Destination.L, MovementType.Move);
		backMoveStyle.put(Destination.UURR, MovementType.Jump);
		backMoveStyle.put(Destination.UULL, MovementType.Jump);
		backMoveStyle.put(Destination.DDRR, MovementType.Jump);
		backMoveStyle.put(Destination.DDLL, MovementType.Jump);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Seer(Player player) {
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