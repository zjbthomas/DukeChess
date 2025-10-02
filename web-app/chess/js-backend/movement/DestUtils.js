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
			case "U":
				ret[0] += player.direction * 1;
				ret[1] += 0;
				break;
			case "D":
				ret[0] += player.direction * -1;
				ret[1] += 0;
				break;
			case "L":
				ret[0] += 0;
				ret[1] += -1;
				break;
			case "R":
				ret[0] += 0;
				ret[1] += 1;
				break;
		}

		return ret;
	}
}

module.exports = DestUtils;
