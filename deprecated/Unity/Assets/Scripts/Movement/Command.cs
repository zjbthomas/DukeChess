using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Command : Movement
{
    public override List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p)
    {
        List<int> ret = new List<int>();

        int[] offsets = DestinationParser.Dest2Offset(d, p);

        if (!IsInField(pos, offsets)) return ret;

        ret.Add(Offset2Dest(pos, DestinationParser.Dest2Offset(d, p)));

        return ret;
    }
}
