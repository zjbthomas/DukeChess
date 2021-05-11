using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementFactory
{
    public enum MovementType {
        Move,
        Jump,
        Slide,
        JumpSlide,
        Strike,
        Command,
        Summon
    }

    private static Move move = new Move();
    private static Jump jump = new Jump();
    private static Slide slide = new Slide();
    private static JumpSlide jumpSlide = new JumpSlide();
    private static Strike strike = new Strike();
    private static Command command = new Command();
    private static Summon summon = new Summon();

    public static Movement CreateMovement(MovementType type) {
        switch (type)
        {
            case MovementType.Move:
                return move;
            case MovementType.Jump:
                return jump;
            case MovementType.Slide:
                return slide;
            case MovementType.JumpSlide:
                return jumpSlide;
            case MovementType.Strike:
                return strike;
            case MovementType.Command:
                return command;
            case MovementType.Summon:
                return summon;
            default:
                return null;
        }
    }
}
