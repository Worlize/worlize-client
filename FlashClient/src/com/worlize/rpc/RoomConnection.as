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
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	public class RoomConnection extends EventDispatcher
	{
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
			
			trace("Connecting to room server: " + url);
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
			trace("Room WebSocket: Connection Opened");
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTED));
		}
		private function handleWebSocketClosed(event:WebSocketEvent):void {
			trace("Room WebSocket: Connection Closed");
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
			trace("Room WebSocket: Connection Fail: " + event.text);
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTION_FAIL));
		}
		private function handleWebSocketIOError(event:WebSocketErrorEvent):void {
			trace("Room WebSocket: IOErrorEvent: " + event.text);
			//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		private function handleWebSocketAbnormalClose(event:WebSocketErrorEvent):void {
			trace("Room WebSocket: Abnormal Close: " + event.text);
		}
		private function handleWebSocketSecurityError(event:SecurityErrorEvent):void {
			trace("Room WebSocket: SecurityErrorEvent: " + event.text);
			//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		
		public function disconnect():void {
			webSocket.close();
		}
	}
}