const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class Command extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);
		
		if (!this.isInField(field, pos, offsets)) return ret;
		
		ret = ret.concat(this.offset2Dest(field, pos, offsets));
		
		return ret;
	}
}

module.exports = Command;
