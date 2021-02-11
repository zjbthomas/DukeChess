package com.dexaint.dukechess.movement;

import static org.junit.Assert.*;
import static org.mockito.Matchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.Arrays;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.dexaint.dukechess.chess.Chess;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class SlideTest {

	Slide slide;
	
	Field field = mock(Field.class);
	Player player = mock(Player.class);
	
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
		slide = new Slide();
		
		when(field.getMaxRow()).thenReturn(6);
		when(field.getMaxCol()).thenReturn(6);
		when(player.getDirection()).thenReturn(1);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testNormalSlide() {
		int pos = 20;
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.U,player),new int[]{26,32}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.D,player),new int[]{14,8,2}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.L,player),new int[]{19,18}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.R,player),new int[]{21,22,23}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UR,player),new int[]{27,34}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UL,player),new int[]{25,30}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DR,player),new int[]{15,10,5}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DL,player),new int[]{13,6}));
	}
	
	@Test
	public void testDeniedSlide() {	
		int pos = 20;
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UUR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UUL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DDR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DDL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.LLU,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.LLD,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.RRU,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.RRD,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DDLL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UUU,player),new int[]{}));
	}

	@Test
	public void testWallCannotSlide() {
		// Case 1: U
		assertTrue(Arrays.equals(slide.validateMovement(field,32,Destination.U,player),new int[]{}));
		// Case 2: D
		assertTrue(Arrays.equals(slide.validateMovement(field,4,Destination.D,player),new int[]{}));
		// Case 3: L
		assertTrue(Arrays.equals(slide.validateMovement(field,18,Destination.L,player),new int[]{}));
		// Case 4: R
		assertTrue(Arrays.equals(slide.validateMovement(field,23,Destination.R,player),new int[]{}));
		// Case 5: UR
		assertTrue(Arrays.equals(slide.validateMovement(field,35,Destination.UR,player),new int[]{}));
		// Case 6: UL
		assertTrue(Arrays.equals(slide.validateMovement(field,30,Destination.UL,player),new int[]{}));
		// Case 7: DR
		assertTrue(Arrays.equals(slide.validateMovement(field,5,Destination.DR,player),new int[]{}));
		// Case 8: DL
		assertTrue(Arrays.equals(slide.validateMovement(field,0,Destination.DL,player),new int[]{}));
	}
	
	@Test
	public void testHasEnemyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(mock(Player.class));
		int pos = 20;
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.U,player),new int[]{26}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.D,player),new int[]{14}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.L,player),new int[]{19}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.R,player),new int[]{21}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UR,player),new int[]{27}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UL,player),new int[]{25}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DR,player),new int[]{15}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DL,player),new int[]{13}));
	}
	
	@Test
	public void testHasMyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(player);
		int pos = 20;
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.U,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.D,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.L,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.R,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.UL,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DR,player),new int[]{}));
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.DL,player),new int[]{}));
	}

	@Test
	public void testSpecialCases() {
		when(field.getChess(22)).thenReturn(mock(Chess.class));
		when(field.getChess(22).getPlayer()).thenReturn(player);
		when(field.getChess(23)).thenReturn(mock(Chess.class));
		when(field.getChess(23).getPlayer()).thenReturn(mock(Player.class));
		int pos = 20;
		assertTrue(Arrays.equals(slide.validateMovement(field,pos,Destination.R,player),new int[]{21}));
	}
}
