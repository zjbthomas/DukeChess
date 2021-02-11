const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class SafeMove extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);

		if (0 != offsets[0] & 0 != offsets[1] & Math.abs(offsets[0]) != Math.abs(offsets[1])) return ret;

		if (!this.isInField(field, pos, offsets) || this.hasAnyChess(field, pos, offsets, p)) return ret; 
		
		offsets[0] = Math.floor(offsets[0] / 2);
		offsets[1] = Math.floor(offsets[1] / 2);
		
		if (0 != offsets[0] || 0 != offsets[1]) {
			if (!this.isInField(field, pos, offsets) || this.hasAnyChess(field, pos, offsets)) return ret;
		}
		
		ret = ret.concat(this.offset2Dest(field, pos, DestUtils.dest2Offset(d, p)));
		
		return ret;
	}
}

module.exports = SafeMove;
