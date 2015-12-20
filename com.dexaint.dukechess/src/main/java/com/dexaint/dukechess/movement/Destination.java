package com.dexaint.dukechess.movement;

import com.dexaint.dukechess.flow.Player;

public enum Destination {
	U,
	D,
	L,
	R,
	UL,
	UR,
	DL,
	DR,
	UU,
	DD,
	LL,
	RR,
	UUL,
	UUR,
	DDL,
	DDR,
	LLU,
	LLD,
	RRU,
	RRD,
	UULL,
	UURR,
	DDLL,
	DDRR,
	UUU;
	
	public int[] dest2Offset(Player player){
		int[] ret = new int[2];
		// ret[0] is UDOffset, ret[1] is LROffset.
		switch (this) {
		case U: ret[0]=player.getDirection() * 1;ret[1]=0;break;
		case D: ret[0]=player.getDirection() * -1;ret[1]=0;break;
		case L: ret[0]=0;ret[1]=-1;break;
		case R: ret[0]=0;ret[1]=1;break;
		case UL: ret=addDests(player,U,L);break;
		case UR: ret=addDests(player,U,R);break;
		case DL: ret=addDests(player,D,L);break;
		case DR: ret=addDests(player,D,R);break;
		case UU: ret=addDests(player,U,U);break;
		case DD: ret=addDests(player,D,D);break;
		case LL: ret=addDests(player,L,L);break;
		case RR: ret=addDests(player,R,R);break;
		case UUL: ret=addDests(player,UU,L);break;
		case UUR: ret=addDests(player,UU,R);break;
		case DDL: ret=addDests(player,DD,L);break;
		case DDR: ret=addDests(player,DD,R);break;
		case LLU:ret=addDests(player,LL,U);break;
		case LLD: ret=addDests(player,LL,D);break;
		case RRU: ret=addDests(player,RR,U);break;
		case RRD: ret=addDests(player,RR,D);break;
		case UULL: ret=addDests(player,UU,LL);break;
		case UURR: ret=addDests(player,UU,RR);break;
		case DDLL: ret=addDests(player,DD,LL);break;
		case DDRR: ret=addDests(player,DD,RR);break;
		case UUU: ret=addDests(player,UU,U);break;
		default: ret = new int[]{};
		}
		return ret;
	}
	
	private int[] addDests(Player player,Destination...ds){
		int[] ret = new int[]{0,0};
		for (Destination d:ds) {
			for (int i = 0; i<=1;i++) {
				ret[i] = ret[i] + d.dest2Offset(player)[i];
			}
		}
		return ret;
	}
}
