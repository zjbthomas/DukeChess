using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;
using UnityEngine;

public class ChessFactory : MonoBehaviour
{
    public static List<XElement> chessList;

    void Awake()
    {
        LoadChessXML();
    }

    static void LoadChessXML() {
        XDocument document = XDocument.Load("Assets/Resources/Configs/Chess.xml");

        chessList = new List<XElement>();
        chessList.AddRange(document.Descendants("chesses").Elements());
    }

    public static void CreateChess(ChessController controller, ChessData.ChessType type, Player player) {
        controller.UpdateChess(type, chessList, player);
    }
}
