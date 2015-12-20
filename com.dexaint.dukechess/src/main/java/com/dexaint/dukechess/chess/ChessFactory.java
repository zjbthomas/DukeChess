package com.dexaint.dukechess.chess;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.io.SAXReader;

import com.dexaint.dukechess.flow.Player;

public class ChessFactory {
	private Document document;
	
	public ChessFactory() {
		try {
			this.document = new SAXReader().read(ChessFactory.class.getResourceAsStream("Chess.xml"));
		} catch (DocumentException e) {
			e.printStackTrace();
		}
	}
	
	public Chess createChess(ChessType type, Player p) {
		return new ChessImpl(p, type, this.document);
	}	
}
