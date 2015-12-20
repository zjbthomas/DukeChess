/*package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class General extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.U, MovementType.Move);
		frontMoveStyle.put(Destination.D, MovementType.Move);
		frontMoveStyle.put(Destination.RR, MovementType.Move);
		frontMoveStyle.put(Destination.LL, MovementType.Move);
		frontMoveStyle.put(Destination.UUR, MovementType.Jump);
		frontMoveStyle.put(Destination.UUL, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.R, MovementType.Move);
		backMoveStyle.put(Destination.RR, MovementType.Move);
		backMoveStyle.put(Destination.L, MovementType.Move);
		backMoveStyle.put(Destination.LL, MovementType.Move);
		backMoveStyle.put(Destination.UUR, MovementType.Jump);
		backMoveStyle.put(Destination.UUL, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> commandStyle;
	static {
		commandStyle = new HashMap<Destination, MovementType>();
		commandStyle.put(Destination.R, MovementType.Command);
		commandStyle.put(Destination.L, MovementType.Command);
		commandStyle.put(Destination.D, MovementType.Command);
		commandStyle.put(Destination.DR, MovementType.Command);
		commandStyle.put(Destination.DL, MovementType.Command);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Command};
	
	public General(Player player) {
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
			case Command:
				if (starter) {
					return null;
				}
				else {
					return commandStyle;
				}
			default:
				return new HashMap<Destination, MovementType>();
		}
	}
}
*/