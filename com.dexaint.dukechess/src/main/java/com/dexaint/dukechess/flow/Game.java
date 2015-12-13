package com.dexaint.dukechess.flow;

public class Game {
	private Player[] playerList = new Player[2];
	private Field field;
	
	private GameState currentState;
	
	public Game(int maxRow, int maxCol) {
		this.playerList[0] = new Player(0,1);
		this.playerList[1] = new Player(1,-1);
		
		this.field = new Field(maxRow, maxCol);
	}
	/*
	private void Initialization() {
		this.currentState = GameState.Initialization;
	}
	private void DukeInit() {
		this.currentState = GameState.DukeInit;
	}
	private void FootmanSummon1() {
		this.currentState = GameState.FootmanSummon1;
	}
	private void FootmanSummon2() {
		this.currentState = GameState.FootmanSummon2;
		
		Initialization();
	}
	*/
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


public GameState getCurrentState()
{
	return currentState;
}

enum GameState {
	/*
	Initialization,
	DukeInit,
	FootmanSummon1,
	FootmanSummon2,
	*/
	INITIALIZATION,
	INITIALSUMMON1,
	INITIALSUMMON2,

}
}
