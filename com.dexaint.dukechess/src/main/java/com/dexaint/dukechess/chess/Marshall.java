package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Marshall extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.R, MovementType.Slide);
		frontMoveStyle.put(Destination.L, MovementType.Slide);
		frontMoveStyle.put(Destination.UURR, MovementType.Jump);
		frontMoveStyle.put(Destination.UULL, MovementType.Jump);
		frontMoveStyle.put(Destination.DD, MovementType.Jump);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Move);
		backMoveStyle.put(Destination.UR, MovementType.Move);
		backMoveStyle.put(Destination.UL, MovementType.Move);
		backMoveStyle.put(Destination.R, MovementType.Move);
		backMoveStyle.put(Destination.RR, MovementType.Move);
		backMoveStyle.put(Destination.L, MovementType.Move);
		backMoveStyle.put(Destination.LL, MovementType.Move);
		backMoveStyle.put(Destination.DR, MovementType.Move);
		backMoveStyle.put(Destination.DL, MovementType.Move);
	}
	
	private static final HashMap<Destination, MovementType> commandStyle;
	static {
		commandStyle = new HashMap<Destination, MovementType>();
		commandStyle.put(Destination.U, MovementType.Command);
		commandStyle.put(Destination.R, MovementType.Command);
		commandStyle.put(Destination.L, MovementType.Command);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Command};
	
	public Marshall(Player player) {
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
					return new HashMap<Destination, MovementType>();
				}
				else {
					return commandStyle;
				}
			default:
				return new HashMap<Destination, MovementType>();
		}
	}
}
