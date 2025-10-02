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

    public Player(int i, int d) {
        this.index = i;
        this.direction = d;
    }
}
