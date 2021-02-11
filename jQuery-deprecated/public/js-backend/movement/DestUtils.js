const DestType = require("./DestType").DestType;

class DestUtils {
	static dest2Offset(ds, player){
		var ret = [0, 0];
		// ret[0] is UDOffset, ret[1] is LROffset.
		for (var d of ds) {
			ret = DestUtils.addDests(ret, player, d);
		}
		return ret;
	}
	
	static addDests(ret, player, d){
		switch (d) {
			case DestType.U:
				ret[0] += player.direction * 1;
				ret[1] += 0;
				break;
			case DestType.D:
				ret[0] += player.direction * -1;
				ret[1] += 0;
				break;
			case DestType.L:
				ret[0] += 0;
				ret[1] += -1;
				break;
			case DestType.R:
				ret[0] += 0;
				ret[1] += 1;
				break;
		}

		return ret;
	}
}

module.exports = DestUtils;
