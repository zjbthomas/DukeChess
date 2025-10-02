const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class Jump extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);
		
		if (1 >= Math.abs(offsets[0]) & 1 >= Math.abs(offsets[1])) return ret;
		
		if (!this.isInField(field, pos, offsets) || this.hasMyChess(field, pos, offsets, p)) return ret;

		ret = ret.concat(this.offset2Dest(field, pos, offsets));
		
		return ret;
	}
}

module.exports = Jump;