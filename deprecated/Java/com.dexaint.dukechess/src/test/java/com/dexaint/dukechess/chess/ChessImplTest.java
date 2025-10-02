package com.dexaint.dukechess.chess;

import static org.junit.Assert.*;
import static org.mockito.Mockito.mock;

import java.util.ArrayList;
import java.util.List;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.dexaint.dukechess.flow.Player;
import com.dexaint.dukechess.movement.Destination;
import com.dexaint.dukechess.movement.MovementType;

public class ChessImplTest {

	ChessImpl chess;
	Player player = mock(Player.class);
	private List<Element> chessList= new ArrayList<Element>();
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
		Document document = new SAXReader().read(ChessFactory.class.getResourceAsStream("Chess.xml"));
		this.chessList = document.getRootElement().elements("chess");
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGetStyle() {
		this.chess = new ChessImpl(this.player,ChessType.Assassin,this.chessList);
		this.chess.starter = false;
		assertTrue(this.chess.getStyle(ActionType.Move).get(Destination.UURR).equals(MovementType.JumpSlide));
	}

}
