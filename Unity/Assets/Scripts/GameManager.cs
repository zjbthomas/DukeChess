using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    public static GameManager gameManager;

    // Bound to UI
    public GameObject message;
    public GameObject board;
    public ChessController chessContainerPrefab;

    // Model of game
    GameModel gameModel;
    
    // Message
    private TextMeshProUGUI msgText;

    // Animation
    private static bool inAnimation;

    public static void SetInAnimation(bool b) {
        inAnimation = b;
    }

    public static bool GetInAnimation() {
        return inAnimation;
    }

    // Menu
    private static bool isWaitingMenu = false;

    public static void SetIsWaitingMenu(bool b)
    {
        isWaitingMenu = b;
    }

    public static bool GetIsWaitingMenu()
    {
        return isWaitingMenu;
    }

    void Awake()
    {
        if (gameManager == null) {
            gameManager = this;
        }
    }

    void Start() {
        // Initialize message box
        this.msgText = message.GetComponent<TextMeshProUGUI>();
    }

    public void StartGame(bool firstPlayer) {
        // Initialize GameModel
        this.gameModel = new GameModel();

        // Create board
        CreateBoard();

        // Initialize players
        gameModel.AddPlayer(new Player(0, 1));
        gameModel.AddPlayer(new Player(1, -1));

        // Start game
        gameModel.StartGame(firstPlayer);
    }

    public GameModel GetGameModel() {
        return this.gameModel;
    }

    void CreateBoard()
    {
        // Initialize list of chess objects
        List<ChessController> chessObjects = new List<ChessController>();

        for (int r = 0; r < GameModel.MAXROW; r++)
        {
            for (int c = 0; c < GameModel.MAXCOL; c++)
            {
                // Instantiate a chess container
                ChessController chess = Instantiate(chessContainerPrefab, new Vector3(0, 0, 0), Quaternion.identity);
                // Set variables
                chess.SetGameModel(this.gameModel);
                chess.SetIndex(r * GameModel.MAXROW + c);
                // Add chess to board
                chess.transform.SetParent(board.transform);
                // Reset transform and scale, respect to board
                chess.transform.localPosition = ChessController.Index2Vec(chess.GetIndex());
                chess.transform.localScale = new Vector3(1, 1, 1);
                // Add chess to list
                chessObjects.Add(chess);
            }
        }

        gameModel.SetBoard(chessObjects);
    }

    public void SetMessage(string msg) {
        this.msgText.SetText(msg);
    }
}
