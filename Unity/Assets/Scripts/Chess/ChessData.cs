using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;
using UnityEngine;

public class ChessData
{
    public enum ChessType
    {
        Assassin,
        Bowman,
        Champion,
        Dragoon,
        Duke,
        Footman,
        General,
        Knight,
        LongBowman,
        Marshall,
        Pikeman,
        Priest,
        Ranger,
        Seer,
        Wizard
    }

    public enum ActionType
    {
        Move,
        Summon,
        Command
    }

    private bool starter;

    public bool GetStarter() {
        return this.starter;
    }

    private Player player;

    public Player GetPlayer() {
        return this.player;
    }

    private ChessType chessType;
    private XElement chessRoot;
    private List<ActionType> actions;

    public ChessData(ChessType type, List<XElement> chessList, Player player) {
        this.starter = true;
        this.player = player;
        this.chessType = type;

        foreach (XElement chess in chessList) {
            // Find the XElement for given ChessType
            if (chess.Attribute("name").Value.Equals(type.ToString())) {
                this.chessRoot = chess;
                // Parse possible actions
                this.actions = new List<ActionType>();
                IEnumerable<XElement> actionList = this.chessRoot.Element("actions").Elements("action");
                foreach (XElement action in actionList) {
                    this.actions.Add((ActionType)Enum.Parse(typeof(ActionType), action.Value));
                }
                break;
            }
        }
    }

    public Dictionary<DestinationParser.Destination, MovementFactory.MovementType> GetStyle(ActionType action) {
        IEnumerable<XElement> styleList = this.chessRoot.Element("styles").Elements("style");

        Dictionary<DestinationParser.Destination, MovementFactory.MovementType> ret = new Dictionary<DestinationParser.Destination, MovementFactory.MovementType>();
        foreach (XElement style in styleList) {
            if (style.Element("action").Value.Equals(action.ToString())) {
                if ((null == style.Element("starter")) || (this.starter ? "1" : "0").Equals(style.Element("starter").Value)) {
                    IEnumerable<XElement> targetList = style.Element("targets").Elements("target");
                    foreach (XElement target in targetList) {
                        ret.Add((DestinationParser.Destination)Enum.Parse(typeof(DestinationParser.Destination), target.Element("destination").Value),
                            (MovementFactory.MovementType)Enum.Parse(typeof(MovementFactory.MovementType), target.Element("movement").Value));
                    }
                    return ret;
                }
            }
        }
        return ret;
    }

    public List<ActionType> getAvailableActions(List<ChessController> board, int pos)
    {
        List<ActionType> ret = new List<ActionType>();
        foreach (ActionType action in actions)
        {
            List<int> dest = GetAvailableDests(board, pos, action);
            if (0 == dest.Count) continue;

            ret.Add(action);
        }
        return ret;
    }

    public List<int> GetAvailableDests(List<ChessController> board, int pos, ActionType action)
    {
        List<int> ret = new List<int>();
        foreach (KeyValuePair<DestinationParser.Destination, MovementFactory.MovementType> kvp in GetStyle(action))
        {
            List<int> dest = MovementFactory.CreateMovement(kvp.Value).ValidateMovement(board, pos, kvp.Key, player);
            ret.AddRange(dest);
        }
        return ret;
    }

    public Dictionary<int, MovementFactory.MovementType> GetAvailableMovements(List<ChessController> board, int pos, ActionType action) {
        Dictionary<int, MovementFactory.MovementType> ret = new Dictionary<int, MovementFactory.MovementType>();
        foreach (KeyValuePair<DestinationParser.Destination, MovementFactory.MovementType> kvp in GetStyle(action)) {
            List<int> dest = MovementFactory.CreateMovement(kvp.Value).ValidateMovement(board, pos, kvp.Key, player);
            foreach (int d in dest) {
                ret.Add(d, kvp.Value);
            }
        }
        return ret;
    }

    public List<int> GetControlArea(List<ChessController> board, int pos)
    {
        List<int> ret = new List<int>();
        foreach (int d in GetAvailableDests(board, pos, ActionType.Move))
        {
            if (!ret.Contains(d)) ret.Add(d);
        }
        foreach (int d in GetAvailableDests(board, pos, ActionType.Command))
        {
            if (!ret.Contains(d)) ret.Add(d);
        }
        return ret;
    }

    public void PerformAction(List<ChessController> board, ActionType action, int[] dest, params object[] objs)
    {
        ChessType? type = null;
        Player p = null;
        foreach (object obj in objs)
        {
            if (obj == null) continue;
            if (obj.GetType() == typeof(ChessType)) {
				type = (ChessType) obj;
}	
			if (obj.GetType() == typeof(Player)) {
				p = (Player) obj;
			}	
		}
		switch (action) {
		case ActionType.Summon:
            ChessFactory.CreateChess(board[dest[0]], (ChessType) type, p);
			p.RemoveFromList((ChessType) type);
			break;
		case ActionType.Move:
            if (GetAvailableMovements(board, dest[0], action)[dest[1]].Equals(MovementFactory.MovementType.Strike))
            {
                    board[dest[1]].DestoryChess();
            }
            starter = !starter;
            break;
		case ActionType.Command:
                // TODO
                break;
}
	}

    public ChessType GetChessType() {
        return this.chessType;
    }
}
