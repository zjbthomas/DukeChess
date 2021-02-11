const ChessFactory = require("../chess/ChessFactory");
const MovementFactory = require("../movement/MovementFactory");

class Field {
	constructor(maxRow, maxCol)
	{
		this.maxRow=maxRow;
        this.maxCol=maxCol;
        
		this.fieldMap= [];
		for(var i = 0; i < this.maxRow * this.maxCol; i++)
            this.fieldMap[i] = null;
            
        this.chessFactory = new ChessFactory();
        this.movementFactory = new MovementFactory();
	}
}

module.exports = Field;