using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;
using UnityEngine;

public class ChessFactory : MonoBehaviour
{
    public static void CreateChess(ChessController controller, ChessData.ChessType type, Player player) {
        controller.UpdateChess(type, player);
    }
}
