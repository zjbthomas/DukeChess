package com.dexaint.dukechess.flow;

import java.util.HashMap;
import java.util.Random;
import java.util.Map.Entry;

import org.apache.commons.lang3.ArrayUtils;

import com.dexaint.dukechess.chess.ChessType;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;
import com.dexaint.dukechess.chess.ActionType;
import com.dexaint.dukechess.chess.Chess;

public class Game {
	private Player[] playerList = new Player[2];
	private Field field;

	private GameState currentState;
	private Player currentPlayer;
	private int currentChessPos;
	private ActionType currentAction;
	private ChessType summonChess;
	private int summonPos;
	private int commandPos;
	
	private boolean waitingMenu;
	
	public Game(int maxRow, int maxCol) {
		this.playerList[0] = new Player(0,1);
		this.playerList[1] = new Player(1,-1);
		
		this.field = new Field(maxRow, maxCol);
		this.currentState = GameState.INITIALIZATION;
		
		this.currentPlayer = this.playerList[0];
	}

	public void Initialization()
	{	
		this.field.setChess(this.field.getChessFactory().createChess(ChessType.Duke, this.playerList[0]), 2);
		this.field.setChess(this.field.getChessFactory().createChess(ChessType.Duke, this.playerList[1]), 33);
		
		this.waitingMenu = false;
		
		this.currentState = GameState.values()[this.currentState.ordinal() + 1];
	}
	
	@SuppressWarnings("incomplete-switch")
	public boolean performState(int userOp) {
		if (!waitingMenu) userOp = this.currentPlayer.equals(this.playerList[0])? userOp: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - userOp);
		
		switch (this.currentState) {
		case INITIALIZATION:
			this.Initialization();
			break;
		case INITSUMMONPLAYERONEFOOTMANONE:
		case INITSUMMONPLAYERONEFOOTMANTWO:
			if (ArrayUtils.contains(this.field.getChess(2).getAvailableDests(this.field, 2, ActionType.Summon), userOp)) {
				this.field.getChess(2).performAction(this.field, ActionType.Summon, new int[]{userOp}, new Object[]{ChessType.Footman, this.playerList[0]});
				
				this.waitingMenu = false;
				if (this.currentState == GameState.INITSUMMONPLAYERONEFOOTMANTWO) {
					this.currentPlayer = this.playerList[1];
				}
				this.currentState = GameState.values()[this.currentState.ordinal() + 1];
			} else return false;
			break;
		case INITSUMMONPLAYERTWOFOOTMANONE:
		case INITSUMMONPLAYERTWOFOOTMANTWO:
			if (ArrayUtils.contains(this.field.getChess(33).getAvailableDests(this.field, 33, ActionType.Summon), userOp)) {
				this.field.getChess(33).performAction(this.field, ActionType.Summon, new int[]{userOp}, new Object[]{ChessType.Footman, this.playerList[1]});
				
				this.waitingMenu = false;
				if (this.currentState == GameState.INITSUMMONPLAYERTWOFOOTMANTWO) {
					this.currentPlayer = this.playerList[0];
				}
				this.currentState = GameState.values()[this.currentState.ordinal() + 1];
			} else return false;
			break;
		case CHOOSECHESS:
			if (this.field.getChess(userOp) == null) return false;
			
			if (this.field.getChess(userOp).getPlayer().equals(this.currentPlayer) == false) return false;
			
			this.currentChessPos = userOp;
			
			this.waitingMenu = true;
			this.currentState = GameState.values()[this.currentState.ordinal() + 1];
			break;
		case CHOOSEACTION:
			if (userOp == 0) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return false;
			}
			
			switch (userOp) {
			case 1:
				this.currentAction = ActionType.Summon;
				this.summonChess = this.currentPlayer.getChessList().get(new Random().nextInt(this.currentPlayer.getChessList().size()));
				break;
			case 2: this.currentAction = ActionType.Move; break;
			case 3: this.currentAction = ActionType.Command; break;
			default: return false;
			}
			
			if (ArrayUtils.contains(this.field.getChess(this.currentChessPos).getAvailableActions(this.field, this.currentChessPos), this.currentAction)) {
				this.waitingMenu = false;
				this.currentState = GameState.values()[this.currentState.ordinal() + 1];
			} else return false;
			break;
		case CHOOSEDESTONE:
			if (!this.currentAction.equals(ActionType.Summon) && userOp == this.currentChessPos) {
				this.waitingMenu = false;
				this.currentState = GameState.CHOOSECHESS;
				return false;
			}
			
			if (ArrayUtils.contains(this.field.getChess(this.currentChessPos).getAvailableDests(this.field, this.currentChessPos, this.currentAction), userOp)) {
				switch (currentAction) {
				case Summon:
					field.setChess(this.field.getChessFactory().createChess(this.summonChess, this.currentPlayer), userOp);
					this.summonPos = userOp;
					
					this.waitingMenu = true;
					this.currentState = GameState.CHOOSEDESTTWO;
					break;
				case Move:
					this.field.getChess(this.currentChessPos).performAction(field, ActionType.Move, new int[]{this.currentChessPos, userOp}, new Object[]{null});
					
					if (this.checkPlayerWin(true) || this.checkPlayerWin(false)) {
						this.waitingMenu = false;
						this.currentState = GameState.ENDSTATE;
						return true;
					} else {
						this.nextTurn();
					}
					break;
				case Command: 
					if (this.field.getChess(userOp) != null && this.field.getChess(userOp).getPlayer().equals(this.currentPlayer)) {
						this.commandPos = userOp;
						
						this.waitingMenu = false;
						this.currentState = GameState.CHOOSEDESTTWO;
					} else return false;
					break;
				default:
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSECHESS;
					return false;
				}
			} else return false;
			break;
		case CHOOSEDESTTWO:
			if ((this.waitingMenu && userOp == 0) || (!this.waitingMenu && userOp == this.currentChessPos)) {
				switch (currentAction) {
				case Summon:
					this.field.setChess(null, summonPos);
					
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSEDESTONE;
					break;
				case Command:
					this.waitingMenu = false;
					this.currentState = GameState.CHOOSECHESS;
					break;
				}
				return false;
			}
			
			switch (currentAction) {
			case Summon:
				if (userOp == 1) {
					this.field.getChess(this.currentChessPos).performAction(this.field, ActionType.Summon, new int[]{this.summonPos}, new Object[]{this.summonChess, this.currentPlayer});
					
					this.nextTurn();
				} else return false;
				break;
			case Command:
				if (userOp != this.commandPos &&
					ArrayUtils.contains(this.field.getChess(currentChessPos).getAvailableDests(this.field, this.currentChessPos, ActionType.Command), userOp) &&
					(this.field.getChess(userOp) == null || !this.field.getChess(userOp).getPlayer().equals(this.currentPlayer))) {
					this.field.getChess(currentChessPos).performAction(this.field, ActionType.Command, new int[]{this.commandPos, userOp}, new Object[]{null});
				} else return false;
				if (this.checkPlayerWin(true) || this.checkPlayerWin(false)) {
					this.currentState = GameState.ENDSTATE;
					return true;
				} else {
					this.nextTurn();
				}
				break;
			}
			break;
		}
		return false;
	}
	
	private void nextTurn() {
		this.currentPlayer = (this.currentPlayer.equals(this.playerList[0]))? this.playerList[1]: this.playerList[0];
		
		this.waitingMenu = false;
		this.currentState = GameState.CHOOSECHESS;
	}
	
	public boolean checkPlayerWin(boolean playerOne) {
		for(int i = 0; i < this.field.getMaxRow() * this.field.getMaxCol(); i++) {
			if (this.field.getChess(i) != null &&
				this.field.getChess(i).getChessType().equals(ChessType.Duke) &&
				this.field.getChess(i).getPlayer().equals(this.playerList[(playerOne? 1: 0)])) return false;
		}
		return true;
	}
	
	public HashMap<Integer, String> getChessMap(boolean playerOne) {
		HashMap<Integer, String> ret = new HashMap<Integer, String>();
		for(int i = 0; i < this.field.getMaxRow() * this.field.getMaxCol(); i++) {
			if (this.field.getChess(i) != null) {
				int pos = playerOne? i: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - i);
				String chess = "url(image/" +
							   this.field.getChess(i).getChessType().toString() +
							   "_" +
							   (this.field.getChess(i).getStarter()? "f": "b") +
							   "_" +
							   ((playerOne == this.field.getChess(i).getPlayer().equals(this.playerList[0]))? 0: 1) +
							   ".png)";
				ret.put(pos, chess);
			}
		}
		return ret;
	}
	
	@SuppressWarnings("incomplete-switch")
	public HashMap<Integer, String> getColorMap(boolean playerOne, boolean hover, int pos) {
		pos = playerOne? pos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - pos);
		
		HashMap<Integer, String> ret = new HashMap<Integer, String>();
		
		if (hover && this.field.getChess(pos) != null) {
			int tPos = playerOne? pos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - pos);
			String color = (playerOne == this.field.getChess(pos).getPlayer().equals(this.playerList[0]))? "blue": "red";
			ret.put(tPos, color);
			
			for (int d : this.field.getChess(pos).getControlArea(this.field, pos)) {
				tPos = playerOne? d: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - d);
				ret.put(tPos, color);
			}
		} else {
			int tPos;
			switch (this.currentState) {
			case INITSUMMONPLAYERONEFOOTMANONE:
			case INITSUMMONPLAYERONEFOOTMANTWO:
				for (Entry<Integer, MovementType> kvp : this.field.getChess(2).getAvailableMovements(this.field, 2, ActionType.Summon).entrySet()) {
					tPos = playerOne? kvp.getKey(): (this.field.getMaxRow() * this.field.getMaxCol() - 1 - kvp.getKey());
					ret.put(tPos, "yellow");
				}
				break;
			case INITSUMMONPLAYERTWOFOOTMANONE:
			case INITSUMMONPLAYERTWOFOOTMANTWO:
				for (Entry<Integer, MovementType> kvp : this.field.getChess(33).getAvailableMovements(this.field, 33, ActionType.Summon).entrySet()) {
					tPos = playerOne? kvp.getKey(): (this.field.getMaxRow() * this.field.getMaxCol() - 1 - kvp.getKey());
					ret.put(tPos, "yellow");
				}
				break;
			case CHOOSECHESS:
				for(int i = 0; i < this.field.getMaxRow() * this.field.getMaxCol(); i++) {
					if (this.field.getChess(i) != null) {
						if (this.field.getChess(i).getPlayer().equals(this.currentPlayer)) {
							tPos = playerOne? i: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - i);
							ret.put(tPos, "blue");
						}
					}
				}
				break;
			case CHOOSEACTION:
				tPos = playerOne? this.currentChessPos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - this.currentChessPos);
				ret.put(tPos, "blue");
				break;
			case CHOOSEDESTONE:
				tPos = playerOne? this.currentChessPos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - this.currentChessPos);
				ret.put(tPos, "blue");
				
				switch (this.currentAction) {
				case Summon:
					for (Entry<Integer, MovementType> kvp : this.field.getChess(this.currentChessPos).getAvailableMovements(this.field, this.currentChessPos, ActionType.Summon).entrySet()) {
						tPos = playerOne? kvp.getKey(): (this.field.getMaxRow() * this.field.getMaxCol() - 1 - kvp.getKey());
						ret.put(tPos, "yellow");
					}
					break;
				case Move:
					for (Entry<Integer, MovementType> kvp : this.field.getChess(this.currentChessPos).getAvailableMovements(this.field, this.currentChessPos, ActionType.Move).entrySet()) {
						tPos = playerOne? kvp.getKey(): (this.field.getMaxRow() * this.field.getMaxCol() - 1 - kvp.getKey());
						switch (kvp.getValue()) {
						case Strike: ret.put(tPos, "red"); break;
						default: ret.put(tPos, "green"); break;
						}
						
					}
					break;
				case Command:
					for (Entry<Integer, MovementType> kvp : this.field.getChess(this.currentChessPos).getAvailableMovements(this.field, this.currentChessPos, ActionType.Command).entrySet()) {
						if (this.field.getChess(kvp.getKey()) != null && this.field.getChess(kvp.getKey()).getPlayer().equals(this.currentPlayer)) {
							tPos = playerOne? kvp.getKey(): (this.field.getMaxRow() * this.field.getMaxCol() - 1 - kvp.getKey());
							ret.put(tPos, "yellow");
						}
					}
					break;
				}
				break;
			case CHOOSEDESTTWO:
				switch (this.currentAction) {
				case Summon:
					tPos = playerOne? this.summonPos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - this.summonPos);
					ret.put(tPos, "yellow");
					
					for (int d : this.field.getChess(this.summonPos).getControlArea(this.field, this.summonPos)) {
						tPos = playerOne? d: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - d);
						ret.put(tPos, "yellow");
					}
					break;
				case Command:
					tPos = playerOne? this.commandPos: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - this.commandPos);
					ret.put(tPos, "yellow");
					
					for (int d : this.field.getChess(this.currentChessPos).getAvailableDests(this.field, this.currentChessPos, ActionType.Command)) {
						if (d != this.commandPos && this.field.getChess(d) != null && !this.field.getChess(d).getPlayer().equals(this.currentPlayer)) {
							tPos = playerOne? d: (this.field.getMaxRow() * this.field.getMaxCol() - 1 - d);
							ret.put(tPos, "yellow");
						}
					}
				}
			}
		}
		
		return ret;
	}
	
	@SuppressWarnings("incomplete-switch")
	public String[] getMenu() {
		String[] ret = new String[]{};
		
		switch (this.currentState) {
		case CHOOSEACTION:
			for (ActionType action : this.field.getChess(this.currentChessPos).getAvailableActions(this.field, this.currentChessPos)) {
				ret = ArrayUtils.add(ret, action.toString());
			}
			ret = ArrayUtils.add(ret, "Cancel");
			break;
		case CHOOSEDESTTWO:
			if (this.currentAction.equals(ActionType.Summon)) {
				ret = ArrayUtils.add(ret, "Confirm");
				ret = ArrayUtils.add(ret, "Cancel");
			}
		}
		
		return ret;
	}
	
	public String getMessage(boolean playerOne) {
		String ret = "";
		
		switch (this.currentState) {
		case INITSUMMONPLAYERONEFOOTMANONE:
			ret = playerOne? "Please summon your first footman." : "Waiting another player to summon footmen.";
			break;
		case INITSUMMONPLAYERONEFOOTMANTWO:
			ret = playerOne? "Please summon your second footman." : "Waiting another player to summon footmen.";
			break;
		case INITSUMMONPLAYERTWOFOOTMANONE:
			ret = !playerOne? "Please summon your first footman." : "Waiting another player to summon footmen.";
			break;
		case INITSUMMONPLAYERTWOFOOTMANTWO:
			ret = !playerOne? "Please summon your second footman." : "Waiting another player to summon footmen.";
			break;
		case CHOOSECHESS:
			ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please choose a chess to perform action." : "Waiting another player to perform action.";
			break;
		case CHOOSEACTION:
			ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please choose an action." : "Waiting another player to perform action.";
			break;
		case CHOOSEDESTONE:
			switch (this.currentAction) {
			case Summon:
				ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? ("You are now summoning " + this.summonChess.toString() + ".") : "Waiting another player to perform action.";
				break;
			case Move:
				ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please choose a place to perform move action." : "Waiting another player to perform action.";
				break;
			case Command:
				ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please choose a chess to command." : "Waiting another player to perform action.";
				break;
			}
			break;
		case CHOOSEDESTTWO:
			switch (this.currentAction) {
			case Summon:
				ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please comfirm your summon action." : "Waiting another player to perform action.";
				break;
			case Command:
				ret = (playerOne == (this.currentPlayer.equals(playerList[0])))? "Please choose a destination for command action." : "Waiting another player to perform action.";
				break;
			}
			break;
		}
		
		return ret;
	}
	
	public int getCurrentPlayer() {
		return (this.playerList[0].equals(this.currentPlayer)? 0: 1);
	}
	
	public boolean getWaitingMenu() {
		return this.waitingMenu;
	}
}

enum GameState {
	INITIALIZATION,
	INITSUMMONPLAYERONEFOOTMANONE,
	INITSUMMONPLAYERONEFOOTMANTWO,
	INITSUMMONPLAYERTWOFOOTMANONE,
	INITSUMMONPLAYERTWOFOOTMANTWO,
	CHOOSECHESS,
	CHOOSEACTION,
	CHOOSEDESTONE,
	CHOOSEDESTTWO,
	ENDSTATE
}
