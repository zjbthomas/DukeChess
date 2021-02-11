const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class CaptureAttempt extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);

		ret = ret.concat(this.storedCapture(field, pos));
		
		if (!this.isInField(field, pos, offsets) || this.hasMyChess(field, pos, offsets, p)) return ret; 
		
		ret = ret.concat(this.offset2Dest(field, pos, offsets));
		
		return ret;
	}
}

module.exports = CaptureAttempt;
