using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Summon : Movement
{
    public override List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p)
    {
        List<int> ret = new List<int>();

        int[] offsets = DestinationParser.Dest2Offset(d, p);

        if (0 != offsets[0] & 0 != offsets[1] & Math.Abs(offsets[0]) != Math.Abs(offsets[1])) return ret;

        if (!(1 == Math.Abs(offsets[0]) || 1 == Math.Abs(offsets[1]))) return ret;

        if (!IsInField(pos, offsets) || HasAnyChess(board, pos, offsets)) return ret;

        ret.Add(Offset2Dest(pos, DestinationParser.Dest2Offset(d, p)));

        return ret;
    }
}
