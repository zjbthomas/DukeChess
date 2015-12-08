package com.dexaint.dukechess.flow;

import java.util.LinkedList;
import com.dexaint.dukechess.chess.ChessType;

public class Player {
	private int index;
	public int getIndex(){return index;}
	private int direction;
	public int getDirection(){return direction;}
	private static LinkedList<ChessType>  chessList = new LinkedList<ChessType>();
	public LinkedList<ChessType> getChessList(){return chessList;}
	
	public Player(int index, int direction)
	{
		this.index=index;
		this.direction=direction;
	}
	static {
		chessList.add(ChessType.Assassin);
		chessList.add(ChessType.Bowman);
		chessList.add(ChessType.Champion);
		chessList.add(ChessType.Dragoon);
		chessList.add(ChessType.Duke);
		chessList.add(ChessType.Footman);
		chessList.add(ChessType.Footman);
		chessList.add(ChessType.Footman);
		chessList.add(ChessType.General);
		chessList.add(ChessType.Knight);
		chessList.add(ChessType.LongBowman);
		chessList.add(ChessType.Marshall);
		chessList.add(ChessType.Pikeman);
		chessList.add(ChessType.Pikeman);
		chessList.add(ChessType.Pikeman);
		chessList.add(ChessType.Priest);
		chessList.add(ChessType.Ranger);
		chessList.add(ChessType.Seer);
		chessList.add(ChessType.Wizard);
	}
}
