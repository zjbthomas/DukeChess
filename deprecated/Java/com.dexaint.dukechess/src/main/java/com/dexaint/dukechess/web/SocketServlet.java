package com.dexaint.dukechess.web;

import java.util.HashMap;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;

import org.apache.catalina.websocket.StreamInbound;
import org.apache.catalina.websocket.WebSocketServlet;

@SuppressWarnings({ "deprecation", "serial" })
@WebServlet(urlPatterns="/controller")
public class SocketServlet extends WebSocketServlet {

	private HashMap<ServletStreamInbound,ServletPeers> pool= new HashMap<>();
	
	@Override
	protected StreamInbound createWebSocketInbound(String arg0, HttpServletRequest request) {
		return new ServletStreamInbound(pool);
	}
}
