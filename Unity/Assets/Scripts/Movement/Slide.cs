﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slide : Movement
{
    public override List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p)
    {
        List<int> ret = new List<int>();

        int[] offsets = DestinationParser.Dest2Offset(d, p);

        if (0 != offsets[0] & 0 != offsets[1] & Math.Abs(offsets[0]) != Math.Abs(offsets[1])) return ret;

        if (1 < Math.Abs(offsets[0]) || 1 < Math.Abs(offsets[1])) return ret;

        int[] moveStep = GetStep(offsets);

        int[] temp = { 0, 0 };
        temp[0] += moveStep[0];
        temp[1] += moveStep[1];

        while (IsInField(pos, temp))
        {
            if (HasMyChess(board, pos, temp, p))
            {
                return ret;
            }
            else if (HasNotMyChess(board, pos, temp, p))
            {
                ret.Add(Offset2Dest(pos, temp));
                return ret;
            }
            else
            {
                ret.Add(Offset2Dest(pos, temp));
            }

            temp[0] += moveStep[0];
            temp[1] += moveStep[1];
        }
        return ret;
    }
}