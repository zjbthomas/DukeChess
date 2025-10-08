using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Strike : Movement
{
    public override List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p)
    {
        List<int> ret = new List<int>();

        int[] offsets = DestinationParser.Dest2Offset(d, p);

        if (!IsInField(pos, offsets) || HasMyChess(board, pos, offsets, p) || !HasAnyChess(board, pos, offsets)) return ret; // Short-Circuit-OR

        ret.Add(Offset2Dest(pos, offsets));

        return ret;
    }
}
