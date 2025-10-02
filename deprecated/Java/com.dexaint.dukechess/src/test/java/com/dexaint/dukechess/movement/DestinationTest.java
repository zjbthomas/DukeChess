package com.dexaint.dukechess.movement;

import static org.junit.Assert.*;

import java.util.Arrays;

import org.junit.Test;

import com.dexaint.dukechess.flow.Player;

import static org.mockito.Mockito.*;

public class DestinationTest {
	
	@Test
	public void testDest2OffsetWithPlayer1() {
		Player player = mock(Player.class);
		when(player.getDirection()).thenReturn(1);

		assertTrue(Arrays.equals(Destination.U.dest2Offset(player),new int[]{1,0}));
		assertTrue(Arrays.equals(Destination.D.dest2Offset(player),new int[]{-1,0}));
		assertTrue(Arrays.equals(Destination.L.dest2Offset(player),new int[]{0,-1}));
		assertTrue(Arrays.equals(Destination.R.dest2Offset(player),new int[]{0,1}));
		assertTrue(Arrays.equals(Destination.UU.dest2Offset(player),new int[]{2,0}));
		assertTrue(Arrays.equals(Destination.DD.dest2Offset(player),new int[]{-2,0}));
		assertTrue(Arrays.equals(Destination.LL.dest2Offset(player),new int[]{0,-2}));
		assertTrue(Arrays.equals(Destination.RR.dest2Offset(player),new int[]{0,2}));
		assertTrue(Arrays.equals(Destination.UL.dest2Offset(player),new int[]{1,-1}));
		assertTrue(Arrays.equals(Destination.UR.dest2Offset(player),new int[]{1,1}));
		assertTrue(Arrays.equals(Destination.DL.dest2Offset(player),new int[]{-1,-1}));
		assertTrue(Arrays.equals(Destination.DR.dest2Offset(player),new int[]{-1,1}));
		assertTrue(Arrays.equals(Destination.UUL.dest2Offset(player),new int[]{2,-1}));
		assertTrue(Arrays.equals(Destination.UUR.dest2Offset(player),new int[]{2,1}));
		assertTrue(Arrays.equals(Destination.DDL.dest2Offset(player),new int[]{-2,-1}));
		assertTrue(Arrays.equals(Destination.DDR.dest2Offset(player),new int[]{-2,1}));
		assertTrue(Arrays.equals(Destination.LLU.dest2Offset(player),new int[]{1,-2}));
		assertTrue(Arrays.equals(Destination.LLD.dest2Offset(player),new int[]{-1,-2}));
		assertTrue(Arrays.equals(Destination.RRU.dest2Offset(player),new int[]{1,2}));
		assertTrue(Arrays.equals(Destination.RRD.dest2Offset(player),new int[]{-1,2}));
		assertTrue(Arrays.equals(Destination.UULL.dest2Offset(player),new int[]{2,-2}));
		assertTrue(Arrays.equals(Destination.UURR.dest2Offset(player),new int[]{2,2}));
		assertTrue(Arrays.equals(Destination.DDLL.dest2Offset(player),new int[]{-2,-2}));
		assertTrue(Arrays.equals(Destination.DDRR.dest2Offset(player),new int[]{-2,2}));
		assertTrue(Arrays.equals(Destination.UUU.dest2Offset(player),new int[]{3,0}));
	}
	
	@Test
	public void testDest2OffsetWithPlayer2() {
		Player player = mock(Player.class);
		when(player.getDirection()).thenReturn(-1);
		
		assertTrue(Arrays.equals(Destination.U.dest2Offset(player),new int[]{-1,0}));
		assertTrue(Arrays.equals(Destination.D.dest2Offset(player),new int[]{1,0}));
		assertTrue(Arrays.equals(Destination.L.dest2Offset(player),new int[]{0,-1}));
		assertTrue(Arrays.equals(Destination.R.dest2Offset(player),new int[]{0,1}));
		assertTrue(Arrays.equals(Destination.UU.dest2Offset(player),new int[]{-2,0}));
		assertTrue(Arrays.equals(Destination.DD.dest2Offset(player),new int[]{2,0}));
		assertTrue(Arrays.equals(Destination.LL.dest2Offset(player),new int[]{0,-2}));
		assertTrue(Arrays.equals(Destination.RR.dest2Offset(player),new int[]{0,2}));
		assertTrue(Arrays.equals(Destination.UL.dest2Offset(player),new int[]{-1,-1}));
		assertTrue(Arrays.equals(Destination.UR.dest2Offset(player),new int[]{-1,1}));
		assertTrue(Arrays.equals(Destination.DL.dest2Offset(player),new int[]{1,-1}));
		assertTrue(Arrays.equals(Destination.DR.dest2Offset(player),new int[]{1,1}));
		assertTrue(Arrays.equals(Destination.UUL.dest2Offset(player),new int[]{-2,-1}));
		assertTrue(Arrays.equals(Destination.UUR.dest2Offset(player),new int[]{-2,1}));
		assertTrue(Arrays.equals(Destination.DDL.dest2Offset(player),new int[]{2,-1}));
		assertTrue(Arrays.equals(Destination.DDR.dest2Offset(player),new int[]{2,1}));
		assertTrue(Arrays.equals(Destination.LLU.dest2Offset(player),new int[]{-1,-2}));
		assertTrue(Arrays.equals(Destination.LLD.dest2Offset(player),new int[]{1,-2}));
		assertTrue(Arrays.equals(Destination.RRU.dest2Offset(player),new int[]{-1,2}));
		assertTrue(Arrays.equals(Destination.RRD.dest2Offset(player),new int[]{1,2}));
		assertTrue(Arrays.equals(Destination.UULL.dest2Offset(player),new int[]{-2,-2}));
		assertTrue(Arrays.equals(Destination.UURR.dest2Offset(player),new int[]{-2,2}));
		assertTrue(Arrays.equals(Destination.DDLL.dest2Offset(player),new int[]{2,-2}));
		assertTrue(Arrays.equals(Destination.DDRR.dest2Offset(player),new int[]{2,2}));
		assertTrue(Arrays.equals(Destination.UUU.dest2Offset(player),new int[]{-3,0}));
	}

}
