using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameModel
{
    // Constants
    public const int MAXROW = 6;
    public const int MAXCOL = 6;

    public enum GameState {
        INITIALIZATION,
        INITSUMMONPLAYERONEFOOTMANONE,
        INITSUMMONPLAYERONEFOOTMANTWO,
        INITSUMMONPLAYERTWOFOOTMANONE,
        INITSUMMONPLAYERTWOFOOTMANTWO,
        CHOOSECHESS,
        CHOOSEACTION,
        CHOOSEDESTONE,
        CHOOSEDESTTWO,
        ENDSTATE
    }

    // Board
    private List<ChessController> board;

    public void SetBoard(List<ChessController> b)
    {
        this.board = b;
    }

    public List<ChessController> GetBoard()
    {
        return this.board;
    }

    // Player
    private List<Player> playerList = new List<Player>();
    private int nowPlayer;

    public void AddPlayer(Player p)
    {
        this.playerList.Add(p);
    }

    public void RemoveFromList(int i, ChessData.ChessType type)
    {
        this.playerList[i].RemoveFromList(type);
    }

    // State
    private GameState nowState;

    public void SetState(GameState s) {
        this.nowState = s;
    }

    public void NextState() {
        this.nowState++;
    }

    private void NextTurn()
    {
        nowPlayer = nowPlayer == 0? 1 : 0;

        waitMenu = false;
        nowState = GameState.CHOOSECHESS;
    }

    private int nowChessPos;

    // Menu
    private bool waitMenu;

    public void SetWaitMenu(bool b) {
        this.waitMenu = b;
    }

    public void StartGame()
    {
        // Add two initial duke
        ChessFactory.CreateChess(board[2], ChessData.ChessType.Duke, playerList[0]);
        ChessFactory.CreateChess(board[33], ChessData.ChessType.Duke, playerList[1]);

        // Remove duke from player's chess
        RemoveFromList(0, ChessData.ChessType.Duke);
        RemoveFromList(1, ChessData.ChessType.Duke);

        // Move to next state
        NextState();

        RenderMask(false, -1);
    }

    public void PerformOp(int userOp)
    {
        switch (nowState)
        {
            case GameState.INITSUMMONPLAYERONEFOOTMANONE:
            case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
                if (board[2].GetChessData().GetAvailableDests(board, 2, ChessData.ActionType.Summon).Contains(userOp))
                {
                    board[2].GetChessData().PerformAction(board, ChessData.ActionType.Summon, new int[] { userOp }, new object[] { ChessData.ChessType.Footman, playerList[0] });

                    waitMenu = false;

                    if (nowState == GameState.INITSUMMONPLAYERONEFOOTMANTWO)
                    {
                        nowPlayer = 1;
                    }
                    NextState();

                    // Play animation
                    board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Generate);
                }
                break;
            case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
            case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
                if (board[33].GetChessData().GetAvailableDests(board, 33, ChessData.ActionType.Summon).Contains(userOp))
                {
                    board[33].GetChessData().PerformAction(board, ChessData.ActionType.Summon, new int[] { userOp }, new object[] { ChessData.ChessType.Footman, playerList[1] });

                    waitMenu = false;
                    if (nowState == GameState.INITSUMMONPLAYERTWOFOOTMANTWO)
                    {
                        nowPlayer = 0;
                    }
                    NextState();

                    // Play animation
                    board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Generate);
                }
                break;
            case GameState.CHOOSECHESS:
                // Empty position?
                if (board[userOp].GetChessData() == null) return;
                // Non-current player?
                if (board[userOp].GetChessData().GetPlayer().GetIndex() != this.nowPlayer) return;

                nowChessPos = userOp;

                waitMenu = true;

                // Play animation
                board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Select);

                // TODO: now temporarily skip action selction
                // NextState();
                nowState = GameState.CHOOSEDESTONE;
                break;
            case GameState.CHOOSEDESTONE:
                // TODO: summon

                // TODO: only handle Move action now
                if (board[nowChessPos].GetChessData().GetAvailableDests(board, nowChessPos, ChessData.ActionType.Move).Contains(userOp)) {
                    // Play animation first
                    board[nowChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Move, userOp);

                    board[nowChessPos].GetChessData().PerformAction(board, ChessData.ActionType.Move, new int[] { nowChessPos, userOp }, new object[] { null });

                    // TODO: check player win

                    NextTurn();
                }
                break;
        }
    }

    public void RenderMask(bool hover, int pos)
    {
        // Reset all masks
        for (int r = 0; r < GameModel.MAXROW; r++)
        {
            for (int c = 0; c < GameModel.MAXCOL; c++)
            {
                // Obtain ChessMask
                GameObject chessMask = board[r * MAXROW + c].transform.Find("ChessMask").gameObject;
                // Change ChessMask active
                chessMask.SetActive(false);
            }
        }

        // Check hovering
        if (hover && pos < 0) {
            return;
        }

        switch (nowState)
        {
            case GameState.INITSUMMONPLAYERONEFOOTMANONE:
            case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
                foreach (KeyValuePair<int, MovementFactory.MovementType> kvp in board[2].GetChessData().GetAvailableMovements(board, 2, ChessData.ActionType.Summon))
                {
                    DyeMask(kvp.Key, MaskColor.YELLOW);
                }
                break;
            case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
            case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
                foreach (KeyValuePair<int, MovementFactory.MovementType> kvp in board[33].GetChessData().GetAvailableMovements(board, 33, ChessData.ActionType.Summon))
                {
                    DyeMask(kvp.Key, MaskColor.YELLOW);
                }
                break;
            case GameState.CHOOSEDESTONE:
                foreach (int p in board[nowChessPos].GetChessData().GetAvailableDests(board, nowChessPos, ChessData.ActionType.Move))
                {
                    DyeMask(p, MaskColor.GREEN);
                }
                break;
        }

        // Handle hovering
        if (hover && board[pos].GetChessData() != null) {
            Color c = board[pos].GetChessData().GetPlayer() == this.playerList[0] ? MaskColor.BLUE : MaskColor.RED;
            // dye hovering chess
            DyeMask(pos, c);
            // dye control area
            foreach (int d in board[pos].GetChessData().GetControlArea(board, pos))
            {
                DyeMask(d, c);
            }
        }
    }

    private void DyeMask(int pos, Color color) {
        // Obtain ChessMask
        GameObject chessMask = board[pos].transform.Find("ChessMask").gameObject;
        // Change ChessMask color to blue
        chessMask.GetComponent<Image>().color = color;
        // Change ChessMask active
        chessMask.SetActive(true);
    }
}
