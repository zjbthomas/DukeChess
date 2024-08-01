const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class Summon extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);
		
		if (0 != offsets[0] & 0 != offsets[1] & Math.abs(offsets[0]) != Math.abs(offsets[1])) return ret;
		
		if (!(1 == Math.abs(offsets[0]) || 1 == Math.abs(offsets[1]))) return ret;
		
		if (!this.isInField(field, pos, offsets) || this.hasAnyChess(field, pos, offsets)) return ret;
		
		ret = ret.concat(this.offset2Dest(field, pos, offsets));
		
		return ret;
	}

	validateControlArea(field, pos, d, p) {
		return [];
	}
}

module.exports = Summon;