package com.dexaint.dukechess.movement;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import static org.mockito.Mockito.*;

import java.util.Arrays;

import com.dexaint.dukechess.chess.Chess;
import com.dexaint.dukechess.flow.Field;
import com.dexaint.dukechess.flow.Player;

public class MoveTest {

	Move move;
	
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
		move = new Move();
		
		when(field.getMaxRow()).thenReturn(6);
		when(field.getMaxCol()).thenReturn(6);
		when(player.getDirection()).thenReturn(1);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testNormalMove() {
		int pos = 20;
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.U,player),new int[]{26}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.D,player),new int[]{14}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.L,player),new int[]{19}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.R,player),new int[]{21}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UU,player),new int[]{32}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DD,player),new int[]{8}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.LL,player),new int[]{18}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.RR,player),new int[]{22}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UR,player),new int[]{27}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UL,player),new int[]{25}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DR,player),new int[]{15}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DL,player),new int[]{13}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UURR,player),new int[]{34}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UULL,player),new int[]{30}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDRR,player),new int[]{10}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDLL,player),new int[]{6}));
	}
	
	@Test
	public void testDeniedMove() {	
		int pos = 20;
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UUR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UUL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.LLU,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.LLD,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.RRU,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.RRD,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UUU,player),new int[]{}));
	}

	@Test
	public void testWallCannotMove() {
		// Case 1: U
		assertTrue(Arrays.equals(move.validateMovement(field,32,Destination.U,player),new int[]{}));
		// Case 2: D
		assertTrue(Arrays.equals(move.validateMovement(field,4,Destination.D,player),new int[]{}));
		// Case 3: L
		assertTrue(Arrays.equals(move.validateMovement(field,18,Destination.L,player),new int[]{}));
		// Case 4: R
		assertTrue(Arrays.equals(move.validateMovement(field,23,Destination.R,player),new int[]{}));
		// Case 5: UU
		assertTrue(Arrays.equals(move.validateMovement(field,26,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,32,Destination.UU,player),new int[]{}));
		// Case 6: DD
		assertTrue(Arrays.equals(move.validateMovement(field,6,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,0,Destination.DD,player),new int[]{}));
		// Case 7: LL
		assertTrue(Arrays.equals(move.validateMovement(field,18,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,19,Destination.LL,player),new int[]{}));
		// Case 8: RR
		assertTrue(Arrays.equals(move.validateMovement(field,28,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,29,Destination.RR,player),new int[]{}));
		// Case 9: UURR
		assertTrue(Arrays.equals(move.validateMovement(field,28,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,35,Destination.UURR,player),new int[]{}));
		// Case 10: UULL
		assertTrue(Arrays.equals(move.validateMovement(field,25,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,30,Destination.UULL,player),new int[]{}));
		// Case 11: DDRR
		assertTrue(Arrays.equals(move.validateMovement(field,5,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,10,Destination.DDRR,player),new int[]{}));
		// Case 12: DDLL
		assertTrue(Arrays.equals(move.validateMovement(field,0,Destination.DDLL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,7,Destination.DDLL,player),new int[]{}));
	}
	
	@Test
	public void testHasEnemyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(mock(Player.class));
		int pos = 20;
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.U,player),new int[]{26}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.D,player),new int[]{14}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.L,player),new int[]{19}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.R,player),new int[]{21}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UR,player),new int[]{27}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UL,player),new int[]{25}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DR,player),new int[]{15}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DL,player),new int[]{13}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDLL,player),new int[]{}));
	}
	
	@Test
	public void testHasMyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(player);
		int pos = 20;
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.U,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.D,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.L,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.R,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(move.validateMovement(field,pos,Destination.DDLL,player),new int[]{}));
	}
}
