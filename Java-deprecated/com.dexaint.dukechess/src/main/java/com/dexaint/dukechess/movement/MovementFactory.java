package com.dexaint.dukechess.movement;

public class MovementFactory {
	private static Move move = new Move();
	private static Jump jump = new Jump();
	private static Slide slide = new Slide();
	private static JumpSlide jumpSlide = new JumpSlide();
	private static Strike strike = new Strike();
	private static Command command = new Command();
	private static Summon summon = new Summon();
	
	public static Movement createMovement(MovementType type) {
		switch (type)
		{
		case Move:
			return move;
		case Jump:
			 return jump;
		case Slide:
			return slide;
		case JumpSlide:
			return jumpSlide;
		case Strike:
			return strike;
		case Command:
			return command;
		case Summon:
			return summon;
		default:
			return null;
		}
	}
}
