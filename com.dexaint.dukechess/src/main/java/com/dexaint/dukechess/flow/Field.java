rt com.dexaint.dukechess.chess.Chess;
import com.dexaint.dukechess.chess.Chess;
import com.dexaint.dukechess.chess.ChessFactory;
import com.dexaint.dukechess.movement.MovementFactory;

public class Field {
	private int maxRow;
	public int getMaxRow(){return maxRow;}
	private int maxCol;
	public int getMaxCol(){return maxCol;}
	private Chess[] fieldMap;
	public Chess getChess(int pos) {return fieldMap[pos];}
	public void setChess(Chess chess, int pos) {fieldMap[pos]=chess;}
	
	private ChessFactory chessFactory = new ChessFactory();
	public ChessFactory getChessFactory() {return chessFactory;}
	private MovementFactory movementFactory = new MovementFactory();
	public MovementFactory getMovementFactory() {return movementFactory;}
	
	public Field(int maxRow, int maxCol)
	{
		this.maxRow=maxRow;
		this.maxCol=maxCol;
		this.fieldMap= new Chess[maxRow*maxCol];
		for(int i=0;i<maxRow*maxCol;i++)
				fieldMap[i]=null;
	}

}
