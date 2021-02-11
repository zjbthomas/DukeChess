package com.dexaint.dukechess.web;

public class PageBuilder {
	private int maxRow;
	private int maxCol;
	private static PageBuilder pageBuilder = new PageBuilder();
	
	private PageBuilder() {
	}
	
	public static PageBuilder getBuilder(){
		return pageBuilder;
	}
	
	public int getMaxRow() {
		return this.maxRow;
	}
	
	public int getMaxCol() {
		return this.maxCol;
	}
	
	public String initPage(int maxRow, int maxCol){
		this.maxRow =  maxRow;
		this.maxCol = maxCol;
		
		StringBuilder ret = new StringBuilder();
		ret.append("<table>\n");
		for (int i=maxRow-1; i>=0;i--) {
			ret.append("\t<tr>\n");
			for (int j=0;j<maxCol;j++) {
				ret.append("\t\t<td><input type=\"image\" id=\"grid_" + (i*maxCol+j) + "\" class=\"grid\" value=\" \"/></td>\n");
			}
			ret.append("\t</tr>\n");
		}
		ret.append("</table>\n");
		
		return ret.toString();
	}
}
