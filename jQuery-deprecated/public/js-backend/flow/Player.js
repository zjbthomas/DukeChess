var fs = require("fs");

class Player {
	constructor(index, direction)
	{
		this.index = index;
		this.direction = direction;
        
        var data = fs.readFileSync(__dirname + "..\\..\\..\\resources\\Player.properties", "utf8");

        var chesses = data.split(",");

        this.chessList = [];
        for (var chess of chesses) {
            this.chessList.push(chess);
        }
    }
    
    removeFromList(type) {
        this.chessList.splice(this.chessList.indexOf(type), 1);
    }
}

module.exports = Player;