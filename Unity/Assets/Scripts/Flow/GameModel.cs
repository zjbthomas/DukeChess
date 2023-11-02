using System;
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

    public void AddPlayer(Player p)
    {
        this.playerList.Add(p);
    }

    bool firstPlayer;

    // Cached chess pos
    private int cachedChessPos;
    private int cachedCommandChess;

    // Cached animation
    private bool isFlying;

    public void StartGame(bool firstPlayer)
    {
        // Set first player
        this.firstPlayer = firstPlayer;

        // Add two initial duke
        ChessFactory.CreateChess(board[2], ChessData.ChessType.Duke, playerList[0]);
        ChessFactory.CreateChess(board[33], ChessData.ChessType.Duke, playerList[1]);

        RenderMask(null);
    }

    public void TryChess(int pos) {
        Dictionary<string, string> json = new Dictionary<string, string>();
        json.Add("type", "grid_click");
        json.Add("grid", "grid_" + pos);

        SocketManager.socketManager.EmitMessage("game", json);
    }

    void TryMenu(string s)
    {
        Dictionary<string, string> json = new Dictionary<string, string>();
        json.Add("type", "menu_click");
        json.Add("value", s);

        SocketManager.socketManager.EmitMessage("game", json);
    }

    public void RenderMenu(Dictionary<string, object> json) {
        if (json != null)
        {
            GameManager.SetIsWaitingMenu(true);

            // Remove all buttons
            UltimateRadialMenu.RemoveAllRadialButtons("ActionMenu");

            // Add buttons
            List<object> menus = (List<object>) json["menus"];
            foreach (object o in menus) {
                string s = o.ToString();

                UltimateRadialButtonInfo info = new UltimateRadialButtonInfo();
                info.name = s;
                info.key = s;
                info.UpdateText(s);

                UltimateRadialMenu.RegisterToRadialMenu("ActionMenu", TryMenu, info);
            }
           
            // Update menu position
            Vector3 scrPos = Camera.main.WorldToScreenPoint(board[cachedChessPos].gameObject.transform.position);
            UltimateRadialMenu.SetPosition("ActionMenu", scrPos);

            UltimateRadialMenu.EnableRadialMenu("ActionMenu");
        }
        else {
            GameManager.SetIsWaitingMenu(false);
            UltimateRadialMenu.DisableRadialMenu("ActionMenu");
            UltimateRadialMenu.SetPosition("ActionMenu", new Vector3(2000, 2000));
        }
    }

    public void PerformOp(Dictionary<string, object> json)
    {
        GameState state = (GameState)int.Parse(json["state"].ToString());
        int userOp = int.Parse(json["userop"].ToString());
        bool active = String.Equals(json["active"], "true");
        string action = "";

        Debug.Log(state);
        Debug.Log(active);

        switch (state)
        {
            case GameState.INITSUMMONPLAYERONEFOOTMANONE:
            case GameState.INITSUMMONPLAYERONEFOOTMANTWO:
                ChessFactory.CreateChess(board[userOp], ChessData.ChessType.Footman, playerList[firstPlayer ? 0 : 1]);
                // Play animation
                board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Generate);
                
                break;
            case GameState.INITSUMMONPLAYERTWOFOOTMANONE:
            case GameState.INITSUMMONPLAYERTWOFOOTMANTWO:
                ChessFactory.CreateChess(board[userOp], ChessData.ChessType.Footman, playerList[firstPlayer ? 1 : 0]);
                // Play animation
                board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Generate);

                break;
            case GameState.CHOOSECHESS:
                // Store current chess pos so the animation can be played later
                cachedChessPos = userOp;

                // Play animation
                if (active)
                {
                    string subtype = json["subtype"].ToString();
                    switch (json["subtype"].ToString()) {
                        case "nomenu":
                            board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Select);
                            isFlying = true;
                            break;
                        case "inmenu":
                            board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.WaitSelect);
                            isFlying = false;
                            break;
                    }
                }
                else {
                    string subtype = json["subtype"].ToString();
                    switch (json["subtype"].ToString())
                    {
                        case "nomenu":
                            board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Select);
                            isFlying = true;
                            break;
                        case "inmenu":
                            board[userOp].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.WaitSelect);
                            isFlying = false;
                            break;
                    }
                }
                break;
            case GameState.CHOOSEACTION:
                if (userOp == 0)
                {
                    board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(isFlying? ChessAnimation.AnimationType.Deselect: ChessAnimation.AnimationType.Kill);
                    isFlying = false;
                    break;
                }
                action = json["action"].ToString();
                switch (action)
                {
                    case "Summon":
                        // Deselect duke at cachedChessPos
                        board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(isFlying ? ChessAnimation.AnimationType.Deselect : ChessAnimation.AnimationType.Kill);
                        isFlying = false;
                        break;
                    case "Move":
                        if (!isFlying) {
                            board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Kill);
                            board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Select);
                            isFlying = true;
                        }
                        break;
                    case "Command":
                        this.cachedCommandChess = cachedChessPos;
                        break;
                }
                break;
            case GameState.CHOOSEDESTONE:
                action = json["action"].ToString();
                
                switch (action) {
                    case "Summon":
                        // Store summon chess pos so the animation can be played later
                        cachedChessPos = userOp;

                        // Summon
                        ChessData.ChessType chessType = (ChessData.ChessType) Enum.Parse(typeof(ChessData.ChessType), json["summon"].ToString());
                        ChessFactory.CreateChess(board[userOp], chessType, playerList[active? 0 : 1]);
                        // Play a deselect sound
                        SoundManager.soundManager.PlayMoveSound();
                        break;
                    case "Move":
                        if (userOp == cachedChessPos)
                        {
                            // If clicking on the selected chess, then cancel action
                            board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Deselect);
                            isFlying = false;
                        }
                        else
                        {
                            if (!isFlying) {
                                board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Kill);
                                isFlying = false;
                            }
                            board[cachedChessPos].GetChessData().Flip();
                            board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Move, userOp);
                        }
                        break;
                    case "Command":
                        // If the command chess is clicked, then cancel
                        if (userOp == this.cachedCommandChess)
                        {
                            board[this.cachedCommandChess].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Kill);
                            break;
                        }
                        // Make command chess WaitSelect
                        board[this.cachedCommandChess].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.WaitSelect);

                        // Store be-commanded chess pos so the animation can be played later
                        cachedChessPos = userOp;
                        
                        board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Select);
                        isFlying = true;
                        break;
                }
                break;
            case GameState.CHOOSEDESTTWO:
                action = json["action"].ToString();

                switch (action)
                {
                    case "Summon":
                        if (userOp == 0) {
                            board[cachedChessPos].DestoryChess();
                            break;
                        }

                        board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Generate);
                        break;
                    case "Command":
                        // If the command chess is clicked, then cancel
                        if (userOp == this.cachedCommandChess) {
                            board[this.cachedCommandChess].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Kill);
                            board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Deselect);
                            isFlying = false;
                            break;
                        }

                        // Move be-commanded chess
                        board[cachedChessPos].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Move, userOp);

                        // Flip command chess
                        board[this.cachedCommandChess].GetChessData().Flip();
                        board[this.cachedCommandChess].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Kill);
                        board[this.cachedCommandChess].gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Flip);
                        break;
                }
                break;
        }
    }

    public void NextState(Dictionary<string, object> json) {
        RenderMask(json);
    }

    public void HandleHover(bool isHovering, int pos) {
        Dictionary<string, string> json = new Dictionary<string, string>();

        if (isHovering)
        {
            json.Add("type", "grid_hover");
            json.Add("grid", "grid_" + pos);
        }
        else {
            json.Add("type", "hover_restore");
            json.Add("grid", "grid_" + pos);
        }
        
        SocketManager.socketManager.EmitMessage("game", json);
    }

    public void RenderMask(Dictionary<string, object> json)
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

        if (json != null)
        {
            foreach (KeyValuePair<string, object> kvp in json)
            {
                string key = kvp.Key;
                if (key.Contains("grid"))
                {
                    int pos = int.Parse(key.Substring("grid_".Length));

                    Color color = MaskColor.TRANSPARENT;
                    switch (kvp.Value.ToString())
                    {
                        case "red":
                            color = MaskColor.RED;
                            break;
                        case "yellow":
                            color = MaskColor.YELLOW;
                            break;
                        case "blue":
                            color = MaskColor.BLUE;
                            break;
                        case "green":
                            color = MaskColor.GREEN;
                            break;
                    }

                    DyeMask(pos, color);
                }
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

    public void PerformGameover(Dictionary<string, object> json) {
        GameManager.gameManager.StartCoroutine(DestroyLosingChessWaiter(json));
        
    }

    IEnumerator DestroyLosingChessWaiter(Dictionary<string, object> json)
    {
        yield return new WaitUntil(() => GameManager.GetInAnimation() == false);

        int userOp = int.Parse(json["userop"].ToString());
        Player winningPlayer = board[userOp].GetChessData().GetPlayer();
        
        foreach (ChessController chess in board) {
            if (chess.GetChessData() != null && chess.GetChessData().GetPlayer() != winningPlayer) {
                GameManager.SetInAnimation(true);
                yield return new WaitForSeconds(0.5F);
                GameManager.SetInAnimation(false);

                chess.gameObject.GetComponent<ChessAnimation>().PlayAnimation(ChessAnimation.AnimationType.Destroy);
                chess.DestoryChess();
            }
        }

    }

    public void StopGame() {
        foreach (ChessController chess in board) {
            chess.DestoryChess();
        }
    }
}
