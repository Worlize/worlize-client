package com.worlize.rpc
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.model.WorlizeConfig;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.SecurityErrorEvent;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	public class RoomConnection extends EventDispatcher
	{
		private var logger:ILogger = Log.getLogger('com.worlize.rpc.RoomConnection');
		
		private var webSocket:WebSocket;
		
		private var config:WorlizeConfig = WorlizeConfig.getInstance();
		
		public function RoomConnection(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function get connected():Boolean {
			if (webSocket && webSocket.connected) {
				return true;
			}
			return false;
		}
		
		public function send(message:Object):void {
			webSocket.sendUTF(JSON.encode(message));
		}
		
		public function connect():void {
			var url:String = config.useTLS ? 'wss://' : 'ws://';
			url += (config.hostname + ":" + config.port + "/" + config.interactivitySession.serverId + "/");
			
			webSocket = new WebSocket(url, FlexGlobals.topLevelApplication.url, 'worlize-interact');
			
			// Disable logger
			webSocket.debug = false;
			
			logger.info("Connecting to room server: " + url);
			webSocket.connect();
			
			webSocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			webSocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			webSocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleWebSocketConnectionFail);
			webSocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, handleWebSocketAbnormalClose);
			webSocket.addEventListener(WebSocketErrorEvent.IO_ERROR, handleWebSocketIOError);
			webSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleWebSocketSecurityError);
		}
		
		private function handleWebSocketOpen(event:WebSocketEvent):void {
			logger.info("Connection Opened");
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTED));
		}
		private function handleWebSocketClosed(event:WebSocketEvent):void {
			logger.info("Connection Closed");
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		private function handleWebSocketMessage(event:WebSocketEvent):void {
			var commEvent:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
			try {
				commEvent.message = JSON.decode(event.message.utf8Data);
			}
			catch (e:Error) {
				commEvent.message = null;
			}
			dispatchEvent(commEvent);
		}
		private function handleWebSocketConnectionFail(event:WebSocketErrorEvent):void {
			logger.info("Connection Fail: " + event.text);
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTION_FAIL));
		}
		private function handleWebSocketIOError(event:WebSocketErrorEvent):void {
			logger.info("IOErrorEvent: " + event.toString());
			//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		private function handleWebSocketAbnormalClose(event:WebSocketErrorEvent):void {
			logger.info("Abnormal Close: " + event.text);
		}
		private function handleWebSocketSecurityError(event:SecurityErrorEvent):void {
			logger.info("SecurityErrorEvent: " + event.toString());
			//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		
		public function disconnect():void {
			webSocket.close();
		}
	}
}