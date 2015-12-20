package com.dexaint.dukechess.flow;

import java.util.LinkedList;
import java.util.Properties;

import com.dexaint.dukechess.chess.ChessType;

public class Player {
	private int index;
	private int direction;
	private LinkedList<ChessType> chessList = new LinkedList<ChessType>();
	
	public Player(int index, int direction)
	{
		this.index=index;
		this.direction=direction;
		
		Properties props = new Properties();
		try {
			props.load(Player.class.getResourceAsStream("Player.properties"));
			String[] chesses = props.get("chesses").toString().split(",");
			for (String chess : chesses) {
				chessList.add(ChessType.valueOf(chess));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public int getIndex() {
		return index;
	}
	
	public int getDirection() {
		return direction;
	}
}
