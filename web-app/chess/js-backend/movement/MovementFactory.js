const MovementType = require("./MovementType").MovementType;
const Move = require("./Move");
const Jump = require("./Jump");
const Slide = require("./Slide");
const Castling = require("./Castling");
const FirstMove = require("./FirstMove");
const SafeMove = require("./SafeMove");
const Capture = require("./Capture");
const CaptureAttempt = require("./CaptureAttempt");

class MovementFactory {
	constructor() {
		this.move = new Move();
		this.jump = new Jump();
		this.slide = new Slide();
		this.castling = new Castling();
		this.firstMove = new FirstMove();
		this.safeMove = new SafeMove();
		this.capture = new Capture();
		this.captureAttempt = new CaptureAttempt();
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
		case MovementType.CASTLING:
			return this.castling;
		case MovementType.FIRSTMOVE:
			return this.firstMove;
		case MovementType.SAFEMOVE:
			return this.safeMove;
		case MovementType.CAPTURE:
			return this.capture;
		case MovementType.CAPTUREATTEMPT:
			return this.captureAttempt;
		default: 
			return null;
		}
	}
}

module.exports = MovementFactory;
