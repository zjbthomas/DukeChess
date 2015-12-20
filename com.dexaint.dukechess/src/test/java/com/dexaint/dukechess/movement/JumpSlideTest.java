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

public class JumpSlideTest {

	JumpSlide jumpSlide;
	
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
		jumpSlide = new JumpSlide();
		
		when(field.getMaxRow()).thenReturn(6);
		when(field.getMaxCol()).thenReturn(6);
		when(player.getDirection()).thenReturn(1);
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testNormalJumpSlide() {
		int pos = 14;
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UU,player),new int[]{26,32}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DD,player),new int[]{2}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.LL,player),new int[]{12}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.RR,player),new int[]{16,17}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UURR,player),new int[]{28,35}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UULL,player),new int[]{24}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDRR,player),new int[]{4}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDLL,player),new int[]{0}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UUU,player),new int[]{32}));
	}
	
	@Test
	public void testDeniedJumpSlide() {	
		int pos = 20;
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.U,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.D,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.L,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.R,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UUR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UUL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.LLU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.LLD,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.RRU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.RRD,player),new int[]{}));
	}

	@Test
	public void testWallCannotJumpSlide() {
		// Case 1: UUR
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,23,Destination.UUR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,29,Destination.UUR,player),new int[]{}));
		// Case 2: UUL
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,18,Destination.UUL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,24,Destination.UUL,player),new int[]{}));
		// Case 3: DDR
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,11,Destination.DDR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,17,Destination.DDR,player),new int[]{}));
		// Case 4: DDL
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,6,Destination.DDL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,12,Destination.DDL,player),new int[]{}));
		// Case 5: LLU
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,31,Destination.LLU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,32,Destination.LLU,player),new int[]{}));
		// Case 6: LLD
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,1,Destination.LLD,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,2,Destination.LLD,player),new int[]{}));
		// Case 7: RRU
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,33,Destination.RRU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,34,Destination.RRU,player),new int[]{}));
		// Case 8: RRD
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,3,Destination.RRD,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,4,Destination.RRD,player),new int[]{}));
		// Case 9: UU
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,26,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,32,Destination.UU,player),new int[]{}));
		// Case 10: DD
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,6,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,0,Destination.DD,player),new int[]{}));
		// Case 11: LL
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,18,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,19,Destination.LL,player),new int[]{}));
		// Case 12: RR
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,28,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,29,Destination.RR,player),new int[]{}));
		// Case 13: UURR
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,28,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,35,Destination.UURR,player),new int[]{}));
		// Case 14: UULL
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,25,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,30,Destination.UULL,player),new int[]{}));
		// Case 15: DDRR
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,5,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,10,Destination.DDRR,player),new int[]{}));
		// Case 16: DDLL
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,0,Destination.DDLL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,7,Destination.DDLL,player),new int[]{}));
		// Case 17: UUU
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,20,Destination.UUU,player),new int[]{}));
	}
	
	@Test
	public void testHasEnemyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(mock(Player.class));
		int pos = 14;
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UU,player),new int[]{26,32}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DD,player),new int[]{2}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.LL,player),new int[]{12}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.RR,player),new int[]{16,17}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UURR,player),new int[]{28,35}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UULL,player),new int[]{24}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDRR,player),new int[]{4}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDLL,player),new int[]{0}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UUU,player),new int[]{32}));
	}
	
	@Test
	public void testHasMyChess() {
		when(field.getChess(anyInt())).thenReturn(mock(Chess.class));
		when(field.getChess(anyInt()).getPlayer()).thenReturn(player);
		int pos = 14;
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UU,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DD,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.LL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.RR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UURR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UULL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDRR,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.DDLL,player),new int[]{}));
		assertTrue(Arrays.equals(jumpSlide.validateMovement(field,pos,Destination.UUU,player),new int[]{}));
	}
}
