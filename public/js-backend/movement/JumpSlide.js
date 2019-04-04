const MovementImpl = require("./MovementImpl");
const DestUtils = require("./DestUtils");

class JumpSlide extends MovementImpl {
	validateMovement(field, pos, d, p) {
		var ret = [];
		
		var offsets = DestUtils.dest2Offset(d, p);
		
		if (0 != offsets[0] & 0 != offsets[1] & Math.abs(offsets[0]) != Math.abs(offsets[1])) return ret;
		
		if ((1 == Math.abs(offsets[0])) || (1 == Math.abs(offsets[1]))) return ret;
		
		if (!this.isInField(field, pos, offsets) || this.hasMyChess(field, pos, offsets, p)) return ret;
		
		ret = ret.concat(this.offset2Dest(field, pos, offsets));
		
		var startPos = this.offset2Dest(field, pos, offsets);
		
		var moveStep = this.getStep(offsets);

		var temp = [0, 0];
		temp[0] += moveStep[0];
		temp[1] += moveStep[1];
		
		while (this.isInField(field, startPos, temp))
		{
			if (this.hasMyChess(field, startPos, temp, p)) 
			{
				return ret;
			}
			else if(this.hasNotMyChess(field, startPos, temp, p))
			{
				ret = ret.concat(this.offset2Dest(field, pos, temp));
				return ret;
			}
			else 
			{
				ret = ret.concat(this.offset2Dest(field, pos, temp));
			}
			
			temp[0] += moveStep[0];
			temp[1] += moveStep[1];
		}
		return ret;
	}
}

module.exports = JumpSlide;
