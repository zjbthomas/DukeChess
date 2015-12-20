package com.dexaint.dukechess.flow;

import java.util.HashMap;

import com.dexaint.dukechess.chess.ChessType;

public class Game {
	private Player[] playerList = new Player[2];
	private Field field;
	HashMap<Integer, String> ret = new HashMap<Integer, String>();
	private GameState currentState;
	
	public Game(int maxRow, int maxCol) {
		this.playerList[0] = new Player(0,1);
		this.playerList[1] = new Player(1,-1);
		
		this.field = new Field(maxRow, maxCol);
		currentState = GameState.INITIALIZATION;
	}

	public HashMap<Integer, String> Initialization()
	{	
		field.setChess(field.getChessFactory().createChess(ChessType.Duke, this.playerList[0]), 2);
		field.setChess(field.getChessFactory().createChess(ChessType.Duke, this.playerList[1]), 33);
		ret.put(new Integer(2), "Duke1");
		ret.put(new Integer(33), "Duke2");
		currentState = GameState.INITIALSUMMON1;
		return ret;
	}
	
	@SuppressWarnings("incomplete-switch")
	public HashMap<Integer, String> performState(int userOp) {
		switch (currentState) {
		case INITIALIZATION:
			return Initialization();
		case INITIALSUMMON1:
			if(userOp == 2)
			{
				ret.put(userOp, "Duke1");
				this.currentState = GameState.INITIALSUMMON2;
				return ret;	
			}
			return null;
			
		}
		return null;
	}
}

enum GameState {
	INITIALIZATION,
	INITIALSUMMON1,
	INITIALSUMMON2,

}
