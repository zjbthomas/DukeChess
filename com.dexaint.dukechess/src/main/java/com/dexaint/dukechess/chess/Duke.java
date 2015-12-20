package com.dexaint.dukechess.chess;

import java.util.HashMap;

import com.dexaint.dukechess.action.ActionType;
import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class Duke extends ChessImpl {
	private static final HashMap<Destination, MovementType> frontMoveStyle;
	static {
		frontMoveStyle = new HashMap<Destination, MovementType>();
		frontMoveStyle.put(Destination.L, MovementType.Slide);
		frontMoveStyle.put(Destination.R, MovementType.Slide);
	}
	
	private static final HashMap<Destination, MovementType> backMoveStyle;
	static {
		backMoveStyle = new HashMap<Destination, MovementType>();
		backMoveStyle.put(Destination.U, MovementType.Slide);
		backMoveStyle.put(Destination.D, MovementType.Slide);
	}
	
	private static final HashMap<Destination, MovementType> summonStyle;
	static {
		summonStyle = new HashMap<Destination, MovementType>();
		summonStyle.put(Destination.U, MovementType.Summon);
		summonStyle.put(Destination.D, MovementType.Summon);
		summonStyle.put(Destination.L, MovementType.Summon);
		summonStyle.put(Destination.R, MovementType.Summon);
	}
	
	private static final ActionType[] actions = new ActionType[]{ActionType.Move, ActionType.Summon};
	
	public Duke(Player player) {
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
			case Summon:
				return summonStyle;
			default:
				return new HashMap<Destination, MovementType>();
		}
	}
}
