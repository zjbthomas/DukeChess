package com.dexaint.dukechess.chess;

import java.util.ArrayList;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import com.dexaint.dukechess.flow.Player;

public class ChessFactory {
	private List<Element> chessList= new ArrayList<Element>();
	
	@SuppressWarnings("unchecked")
	public ChessFactory() {
		try {
			Document document = new SAXReader().read(ChessFactory.class.getResourceAsStream("Chess.xml"));
			this.chessList = document.getRootElement().elements("chess");
		} catch (DocumentException e) {
			e.printStackTrace();
		}
	}
	
	public Chess createChess(ChessType type, Player p) {
		return new ChessImpl(p, type, this.chessList);
	}	
}
