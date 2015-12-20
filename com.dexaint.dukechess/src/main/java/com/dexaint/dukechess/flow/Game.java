package com.dexaint.dukechess.flow;

import com.dexaint.dukechess.chess.Chess;
import com.dexaint.dukechess.chess.ChessType;

public class Game {
	private Player[] playerList = new Player[2];
	private Field field;
	
	private GameState currentState;
	
	public Game(int maxRow, int maxCol) {
		this.playerList[0] = new Player(0,1);
		this.playerList[1] = new Player(1,-1);
		
		this.field = new Field(maxRow, maxCol);
	}

	public void Initialization()
	{
		currentState = GameState.INITIALIZATION;
		Chess[] map = field.getFieldMap();
		map[2] = field.getChessFactory().createChess(ChessType.Duke, this.playerList[0]);
		map[33] = field.getChessFactory().createChess(ChessType.Duke, this.playerList[1]);
		currentState = GameState.INITIALSUMMON1;
		PerformState();
	}
	
	public void PerformState() {
		switch (currentState) {
		case INITIALSUMMON1:
			// Do something
			this.currentState = GameState.INITIALSUMMON2;
		}
	}
}

enum GameState {
	INITIALIZATION,
	INITIALSUMMON1,
	INITIALSUMMON2,

}
