package com.dexaint.dukechess.flow;

public class Game {
	private Player[] playerList = new Player[2];
	private Field field;
	
	private GameState currentState;
	
	public Game(int maxRow, int maxCol) {
		this.playerList[0] = new Player(0,1);
		this.playerList[1] = new Player(1,-1);
		
		this.field = new Field(maxRow, maxCol);
		
		Initialization();
	}
	
	private void Initialization() {
		this.currentState = GameState.INITIALIZATION;
		// Do something
		this.currentState= GameState.INITIALSUMMON1;
	}
	
	public void NextStep(int userOp) {
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
