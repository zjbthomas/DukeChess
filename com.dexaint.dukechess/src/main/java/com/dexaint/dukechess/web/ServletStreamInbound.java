package com.dexaint.dukechess.web;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;
import java.nio.CharBuffer;
import java.util.HashMap;
import java.util.Map.Entry;

import org.apache.catalina.websocket.StreamInbound;
import org.apache.catalina.websocket.WsOutbound;

import com.google.gson.Gson;

@SuppressWarnings("deprecation")
public class ServletStreamInbound extends StreamInbound {

	private HashMap<ServletStreamInbound,ServletPeers> pool;
	
	public ServletStreamInbound(HashMap<ServletStreamInbound,ServletPeers> pool) {
		this.pool = pool;
	}
	
	@Override
	protected void onBinaryData(InputStream arg0) throws IOException {
	}

	@Override
	protected void onTextData(Reader reader) throws IOException {
		char[] chArr = new char[1024];  
        int len = reader.read(chArr);  
        String message = String.copyValueOf(chArr, 0, len);
		@SuppressWarnings("unchecked")
		HashMap<Object, Object> inMsg = new Gson().fromJson(message, HashMap.class);
		
		ServletPeers peers = pool.get(this);
		
		if (null != peers) {
			peers.getApp().execute(this, inMsg);
		}
		else
		{
			HashMap<Object, Object> out = new HashMap<>();
			out.put("connection", "false");
			out.put("message", "Wait for another player to join");
			this.send(out);
		}
	}
	
	@Override
	protected void onOpen(WsOutbound outbound) {
		super.onOpen(outbound);
		if (!pool.containsKey(this)) {
			pool.put(this, null);
			if (!this.matching()) {
				HashMap<Object, Object> out = new HashMap<>();
				out.put("connection", "false");
				out.put("message", "Wait for another player to join");
				this.send(out);
			}
		}
	}
	
	@Override  
    protected void onClose(int status) {  
		ServletPeers peers = pool.get(this);
		pool.remove(this);
		
		if (null != peers) {
			ServletStreamInbound peerSession = (peers.getFirst() == this)?peers.getSecond():peers.getFirst();
			pool.put(peerSession, null);
			if (!peerSession.matching()) {
				HashMap<Object, Object> out = new HashMap<>();
				out.put("connection", "false");
				out.put("message", "Wait for another player to join");
				peerSession.send(out);
			}
		}
        super.onClose(status);  
    }
	
	private boolean matching() {
		for (Entry<ServletStreamInbound, ServletPeers> entry : pool.entrySet()) {
			ServletStreamInbound nowSession = entry.getKey();
			ServletPeers nowPeers = entry.getValue();
			if (!nowSession.equals(this) && // Short-circuit AND
					null == nowPeers) {
				ServletPeers newPeers = new ServletPeers(this, nowSession);
				pool.put(this, newPeers);
				pool.put(nowSession, newPeers);
				
				HashMap<Object, Object> out = new HashMap<>();
				out.put("connection", "true");
				out.put("message", "Connection established.");
				this.send(out);
				nowSession.send(out);
				
				return true;
			}
		}
		return false;
	}
	
	public void send(HashMap<Object, Object> out) {
		try {
			getWsOutbound().writeTextMessage(CharBuffer.wrap(new Gson().toJson(out)));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
