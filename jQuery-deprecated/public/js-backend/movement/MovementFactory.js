const MovementType = require("./MovementType").MovementType;
const Move = require("./Move");
const Jump = require("./Jump");
const Slide = require("./Slide");
const JumpSlide = require("./JumpSlide");
const Strike = require("./Strike");
const Command = require("./Command");
const Summon = require("./Summon");

class MovementFactory {
	constructor() {
		this.move = new Move();
		this.jump = new Jump();
		this.slide = new Slide();
		this.jumpSlide = new JumpSlide();
		this.strike = new Strike();
		this.command = new Command();
		this.summon = new Summon();
	}

	createMovement(type) {
		switch (type)
		{
		case MovementType.MOVE:
			return this.move;
		case MovementType.JUMP:
			 return this.jump;
		case MovementType.SLIDE:
			return this.slide;
		case MovementType.JUMPSLIDE:
			return this.jumpSlide;
		case MovementType.STRIKE:
			return this.strike;
		case MovementType.COMMAND:
			return this.command;
		case MovementType.SUMMON:
			return this.summon;
		default: 
			return null;
		}
	}
}

module.exports = MovementFactory;
