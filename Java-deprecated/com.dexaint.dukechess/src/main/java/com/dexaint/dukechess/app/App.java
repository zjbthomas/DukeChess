package com.dexaint.dukechess.app;

import java.util.HashMap;

import com.dexaint.dukechess.web.ServletStreamInbound;

public interface App {
	public void execute(ServletStreamInbound eventPoint, HashMap<Object, Object> inMsg);
}
