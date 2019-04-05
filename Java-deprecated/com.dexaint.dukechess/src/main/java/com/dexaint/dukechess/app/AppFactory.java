package com.dexaint.dukechess.app;

import com.dexaint.dukechess.flow.Controller;
import com.dexaint.dukechess.web.ServletStreamInbound;

public class AppFactory {
	public static App createApp(AppType type, ServletStreamInbound first, ServletStreamInbound second) {
		switch (type)
		{
		case DukeGame:
			return new Controller(first, second);
		default:
			return null;
		}
	}
}
