package com.dexaint.dukechess.web;

import com.dexaint.dukechess.app.App;
import com.dexaint.dukechess.app.AppFactory;
import com.dexaint.dukechess.app.AppType;

public class ServletPeers {
	private ServletStreamInbound firstPoint;
	private ServletStreamInbound secondPoint;
	
	private App app;
	
	public ServletPeers(ServletStreamInbound first, ServletStreamInbound second) {
		this.firstPoint = first;
		this.secondPoint = second;
		
		app = AppFactory.createApp(AppType.DukeGame, first, second);
	}
	
	public ServletStreamInbound getFirst() {
		return this.firstPoint;
	}
	
	public ServletStreamInbound getSecond() {
		return this.secondPoint;
	}
	
	public App getApp() {
		return this.app;
	}
}
