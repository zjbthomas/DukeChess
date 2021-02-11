
var fs = require("fs");
var xmldoc = require("xmldoc");
var ChessImpl = require("./ChessImpl");

class ChessFactory {
  constructor() {
    var data = fs.readFileSync(__dirname + "..\\..\\..\\resources\\Chess.xml");
    var document = new xmldoc.XmlDocument(data);
    
    this.chessList = document.childrenNamed("chess");
  }
    
  createChess(type, p) {
		return new ChessImpl(p, type, this.chessList);
  }
}

module.exports = ChessFactory;