using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEngine;

public class Player {
    private int index;

    public int GetIndex() {
        return this.index;
    }

    private int direction;

    public int GetDirection() {
        return this.direction;
    }

    private List<string> chessList;

    public Player(int i, int d) {
        this.index = i;
        this.direction = d;

        // Read player's chess list
        StreamReader reader = new StreamReader("Assets/Resources/Configs/Player.properties");
        string data = reader.ReadToEnd();
        this.chessList = data.Split(',').ToList();
    }

    public void RemoveFromList(ChessData.ChessType type) {
        this.chessList.Remove(type.ToString()); // Not safe to cast Enum to string, but temporarily use it
    }
}
