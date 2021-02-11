const { ChessType } = require("../chess/ChessType");

class MovementImpl {
	offset2Dest(field, pos, offsets) {
		return pos + offsets[0] * field.maxRow + offsets[1];
	}
	
	isInField(field, pos, offsets) {
		var posOffsets = this.pos2RowCol(field, pos);
		return (posOffsets[0] + offsets[0] >= 0) & (posOffsets[0] + offsets[0] < field.maxRow)
				& (posOffsets[1] + offsets[1] >= 0) & (posOffsets[1] + offsets[1] < field.maxCol);
	}
	
	hasAnyChess(field, pos, offsets) {
		return (null != field.fieldMap[this.offset2Dest(field, pos, offsets)]);
	}
	
	hasMyChess(field, pos, offsets, p) {
		return this.hasAnyChess(field, pos, offsets) && 
				(field.fieldMap[this.offset2Dest(field, pos, offsets)].player == p);
	}
	
	hasNotMyChess(field, pos, offsets, p) {
		return this.hasAnyChess(field, pos, offsets) && 
				!this.hasMyChess(field, pos, offsets, p);
	}

	allowFirstMove(field, pos) {
		return (field.fieldMap[pos] != null &&
				field.fieldMap[pos].chessType == ChessType.PAWN &&
				field.fieldMap[pos].firstMove);
	}
	
	storedCapture(field, pos) {
		if (field.fieldMap[pos] !=null && field.fieldMap[pos].capture != null) {
			return field.fieldMap[pos].capture;
		} else {
			return [];
		}
	}
	
	hasMyUnmovedRook(field, pos, offsets, p) {
		return (this.hasAnyChess(field, pos, offsets) &&
				field.fieldMap[this.offset2Dest(field, pos, offsets)].player == p &&
				field.fieldMap[this.offset2Dest(field, pos, offsets)].chessType == ChessType.ROOK &&
				field.fieldMap[this.offset2Dest(field, pos, offsets)].castling);
	}

	pos2RowCol(field, pos) {
		var ret = [];
		ret[0] = Math.floor(pos / field.maxCol);;
		ret[1] = pos % field.maxCol;
		return ret;
	}
	
	getStep(offsets)
	{
		var step = [0, 0];
		if(offsets[0] > 0)
			step[0] = 1;
		else if(offsets[0] < 0)
			step[0] = -1;
		
		if(offsets[1] > 0)
			step[1] = 1;
		else if(offsets[1] < 0)
			step[1] = -1;
		return step;
	}
}

module.exports = MovementImpl;
