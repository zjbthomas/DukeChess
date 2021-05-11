using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;
using UnityEngine;
using UnityEngine.UI;

public class ChessController : MonoBehaviour
{
    // Constants
    private const int CORNER = -450;
    private const int OFFSET = 180;

    // Bound to a ChessData
    private ChessData chessData;

    public ChessData GetChessData() {
        return this.chessData;
    }

    // Bound to UI
    public GameObject chessEntity;

    public Image front;
    public Image back;
    public Image mask;

    // Bound to GameModel
    private GameModel gameModel;

    public void SetGameModel(GameModel gm)
    {
        this.gameModel = gm;
    }
    public GameModel GetGameModel()
    {
        return this.gameModel;
    }

    // Index
    private int index;

    public void SetIndex(int i)
    {
        this.index = i;
    }

    public int GetIndex() {
        return this.index;
    }

    public void Awake()
    {
        if (this.chessData != null) {
            DestoryChess();
        }
    }

    public void UpdateChess(ChessData.ChessType type, List<XElement> chessList, Player player) {
        // Create new ChessData
        this.chessData = new ChessData(type, chessList, player);

        // Set front and back image
        this.front.sprite = Resources.Load<Sprite>("Graphics/UI/Chess/"
            + this.chessData.GetChessType().ToString() + "_f_"
            + this.chessData.GetPlayer().GetIndex());

        this.back.sprite = Resources.Load<Sprite>("Graphics/UI/Chess/"
            + this.chessData.GetChessType().ToString() + "_b_"
            + this.chessData.GetPlayer().GetIndex());

        // Set mask color
        this.mask.color = MaskColor.TRANSPARENT;

        // Set ChessEntity active
        this.chessEntity.SetActive(true);
    }

    public void DestoryChess()
    {                       
        this.chessData = null;
        // Set ChessEntity and mask to inactive
        this.chessEntity.SetActive(false);
        this.mask.gameObject.SetActive(false);
    }

    public static Vector3 Index2Vec(int i) {
        int r = i / GameModel.MAXROW;
        int c = i % GameModel.MAXROW;
        return new Vector3(CORNER + c * OFFSET, CORNER + r * OFFSET, 0);
    }
}
