using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Movement
{
    public abstract List<int> ValidateMovement(List<ChessController> board, int pos, DestinationParser.Destination d, Player p);

    protected int[] Pos2RowCol(int pos)
    {
        int[] ret = new int[2];
        ret[0] = pos / GameModel.MAXCOL;
        ret[1] = pos % GameModel.MAXROW;
        return ret;
    }

    protected int Offset2Dest(int pos, int[] offsets)
    {
        return pos + offsets[0] * GameModel.MAXROW + offsets[1];
    }

    protected bool IsInField(int pos, int[] offsets)
    {
        int[] posOffsets = Pos2RowCol(pos);
        return (posOffsets[0] + offsets[0] >= 0) & (posOffsets[0] + offsets[0] < GameModel.MAXROW)
                & (posOffsets[1] + offsets[1] >= 0) & (posOffsets[1] + offsets[1] < GameModel.MAXCOL);
    }

    

    protected bool HasAnyChess(List<ChessController> board, int pos, int[] offsets)
    {
        return (null != board[Offset2Dest(pos, offsets)].GetChessData());
    }

    protected bool HasMyChess(List<ChessController> board, int pos, int[] offsets, Player p)
    {
        return HasAnyChess(board, pos, offsets) && // Short-circuit-AND
                (board[Offset2Dest(pos, offsets)].GetChessData().GetPlayer().Equals(p));
    }

    protected bool HasNotMyChess(List<ChessController> board, int pos, int[] offsets, Player p)
    {
        return HasAnyChess(board, pos, offsets) && // Short-circuit-AND
                !HasMyChess(board, pos, offsets, p);
    }

    protected int[] GetStep(int[] offsets)
    {
        int[] step = { 0, 0 };
        if (offsets[0] > 0)
            step[0] = 1;
        else if (offsets[0] < 0)
            step[0] = -1;

        if (offsets[1] > 0)
            step[1] = 1;
        else if (offsets[1] < 0)
            step[1] = -1;
        return step;
    }
}
