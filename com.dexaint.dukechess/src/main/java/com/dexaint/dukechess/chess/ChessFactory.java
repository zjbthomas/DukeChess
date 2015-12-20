package com.dexaint.dukechess.chess;

import com.dexaint.dukechess.flow.Player;

public class ChessFactory {
	
	public Chess createChess(ChessType type, Player p) {
		switch (type)
		{
		case Assassin:
			return new Assassin(p);
		case Bowman:
			return new Bowman(p);
		case Champion:
			return new Champion(p);
		case Dragoon:
			return new Dragoon(p);
		case Duke:
			return new Duke(p);
		case Footman:
			return new Footman(p);
		case General:
			return new General(p);
		case Knight:
			return new Knight(p);
		case Pikeman:
			return new Pikeman(p);
		case Priest:
			return new Priest(p);
		case Ranger:
			return new Ranger(p);
		case Seer:
			return new Seer(p);
		case Wizard:
			return new Wizard(p);	
		default:
			return null;
		}
	}	
}
