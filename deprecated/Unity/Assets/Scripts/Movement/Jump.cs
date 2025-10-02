using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Jump : Movement
{
    public override List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p)
    {
        List<int> ret = new List<int>();

        int[] offsets = DestinationParser.Dest2Offset(d, p);

        if (1 >= Math.Abs(offsets[0]) && 1 >= Math.Abs(offsets[1])) return ret;

        if (!IsInField(pos, offsets) || HasMyChess(board, pos, offsets, p)) return ret;

        if (!IsInField(pos, offsets)) return ret;

        ret.Add(Offset2Dest(pos, offsets));

        return ret;
    }
}
