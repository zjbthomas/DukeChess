using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestinationParser
{
    public enum Destination
    {
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
        UUU
    }

    public static int[] Dest2Offset(Destination d, Player player)
    {
        int[] ret = new int[2];
        // ret[0] is UDOffset, ret[1] is LROffset.
        switch (d)
        {
            case Destination.U: ret[0] = player.GetDirection() * 1; ret[1] = 0; break;
            case Destination.D: ret[0] = player.GetDirection() * -1; ret[1] = 0; break;
            case Destination.L: ret[0] = 0; ret[1] = -1; break;
            case Destination.R: ret[0] = 0; ret[1] = 1; break;
            case Destination.UL: ret = AddDests(player, Destination.U, Destination.L); break;
            case Destination.UR: ret = AddDests(player, Destination.U, Destination.R); break;
            case Destination.DL: ret = AddDests(player, Destination.D, Destination.L); break;
            case Destination.DR: ret = AddDests(player, Destination.D, Destination.R); break;
            case Destination.UU: ret = AddDests(player, Destination.U, Destination.U); break;
            case Destination.DD: ret = AddDests(player, Destination.D, Destination.D); break;
            case Destination.LL: ret = AddDests(player, Destination.L, Destination.L); break;
            case Destination.RR: ret = AddDests(player, Destination.R, Destination.R); break;
            case Destination.UUL: ret = AddDests(player, Destination.UU, Destination.L); break;
            case Destination.UUR: ret = AddDests(player, Destination.UU, Destination.R); break;
            case Destination.DDL: ret = AddDests(player, Destination.DD, Destination.L); break;
            case Destination.DDR: ret = AddDests(player, Destination.DD, Destination.R); break;
            case Destination.LLU: ret = AddDests(player, Destination.LL, Destination.U); break;
            case Destination.LLD: ret = AddDests(player, Destination.LL, Destination.D); break;
            case Destination.RRU: ret = AddDests(player, Destination.RR, Destination.U); break;
            case Destination.RRD: ret = AddDests(player, Destination.RR, Destination.D); break;
            case Destination.UULL: ret = AddDests(player, Destination.UU, Destination.LL); break;
            case Destination.UURR: ret = AddDests(player, Destination.UU, Destination.RR); break;
            case Destination.DDLL: ret = AddDests(player, Destination.DD, Destination.LL); break;
            case Destination.DDRR: ret = AddDests(player, Destination.DD, Destination.RR); break;
            case Destination.UUU: ret = AddDests(player, Destination.UU, Destination.U); break;
        }
        return ret;
    }

    private static int[] AddDests(Player player, params Destination[] ds)
    {
        int[] ret = new int[] { 0, 0 };
        foreach (Destination d in ds)
        {
            for (int i = 0; i <= 1; i++)
            {
                ret[i] = ret[i] + Dest2Offset(d, player)[i];
            }
        }
        return ret;
    }
}
