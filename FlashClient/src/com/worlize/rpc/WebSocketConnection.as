package com.worlize.rpc
{
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.interactivity.rpc.messages.IBinaryServerMessage;
	import com.worlize.model.WorlizeConfig;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import com.worlize.websocket.WebSocketState;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connectionFail")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="stateChange")]
	public class WebSocketConnection extends EventDispatcher
	{
		// Must be set by subclass constructor
		protected var logger:ILogger;
		
		protected var webSocket:WebSocket;
		
		protected var _state:String = WorlizeConnectionState.INIT;
		
		public function WebSocketConnection(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		// Abstract Getter
		public function get url():String {
			throw new Error("function get url():String must be implemented by subclass.");
		}
		
		// Abstract Getter
		public function get protocol():String {
			throw new Error("function get protocol():String must be implemented by subclass.");
		}
		
		// Expose the current state
		[Bindable(event="stateChange")]
		public function get state():String {
			return _state;
		}
		
		// Always use this function to change the internal state and it will
		// automatically dispatch the appropriate events.
		protected function setState(newState:String):void {
			if (_state !== newState) {
				var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.STATE_CHANGE);
				event.previousState = _state;
				event.newState = newState;
				_state = newState;
				dispatchEvent(event);
				
				switch (newState) {
					case WorlizeConnectionState.CONNECTED:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTED));
						break;
					case WorlizeConnectionState.DISCONNECTED:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
						break;
					case WorlizeConnectionState.CONNECTING:
						dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTING));
						break;
					default:
						break;
				}
			}
		}

		public function get connected():Boolean {
			return _state === WorlizeConnectionState.CONNECTED;
		}
		
		public function send(message:Object):void {
			if (_state !== WorlizeConnectionState.CONNECTED) {
				throw new Error("Cannot send message.  Not connected.");
			}
			if (message is IBinaryServerMessage) {
				webSocket.sendBytes((message as IBinaryServerMessage).serialize());
			}
			else {
				webSocket.sendUTF(JSON.stringify(message));
			}
		}
		
		public function connect():void {
			if (_state === WorlizeConnectionState.CONNECTED ||
				_state === WorlizeConnectionState.CONNECTING) {
				logger.warn("Already connected or connecting - Ignoring request to connect");
				return;
			}

			setState(WorlizeConnectionState.CONNECTING);
			
			doConnect();
		}
		
		protected function doConnect():void {
			webSocket = new WebSocket(url, FlexGlobals.topLevelApplication.url, protocol);
			
			// Disable logger
			webSocket.debug = false;
			
			webSocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			webSocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			webSocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleWebSocketConnectionFail);
			webSocket.addEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, handleWebSocketAbnormalClose);
			webSocket.addEventListener(IOErrorEvent.IO_ERROR, handleWebSocketIOError);
			webSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleWebSocketSecurityError);
			
			logger.info("Opening WebSocket To: " + url);
			webSocket.connect();
		}
		
		public function disconnect():void {
			if (_state === WorlizeConnectionState.CONNECTED ||
				_state === WorlizeConnectionState.CONNECTING)
			{
				webSocket.close();
			}
		}
		
		protected function removeWebSocketEventListeners():void {
			if (webSocket === null) { return; }
			webSocket.removeEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			webSocket.removeEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			webSocket.removeEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			webSocket.removeEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleWebSocketConnectionFail);
			webSocket.removeEventListener(WebSocketErrorEvent.ABNORMAL_CLOSE, handleWebSocketAbnormalClose);
			webSocket.removeEventListener(IOErrorEvent.IO_ERROR, handleWebSocketIOError);
			webSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handleWebSocketSecurityError);
		}
		
		protected function handleWebSocketOpen(event:WebSocketEvent):void {
			logger.info("Connection Opened");
			setState(WorlizeConnectionState.CONNECTED);
		}
		
		protected function handleWebSocketClosed(event:WebSocketEvent):void {
			logger.info("Connection Closed");
			removeWebSocketEventListeners();
			webSocket = null;
			setState(WorlizeConnectionState.DISCONNECTED);				
		}
		
		
		// Event Handlers:
		
		protected function handleWebSocketMessage(event:WebSocketEvent):void {
			var commEvent:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
			if (event.message.type === WebSocketMessage.TYPE_BINARY) {
				commEvent.binaryData = event.message.binaryData;
			}
			else {
				try {
					commEvent.message = JSON.parse(event.message.utf8Data);
				}
				catch (e:Error) {
					logger.error("Unparsable message received.");
					return;
				}
			}
			dispatchEvent(commEvent);
		}
		
		protected function handleWebSocketConnectionFail(event:WebSocketErrorEvent):void {
			logger.info("Websocket Connection Failed: " + event.text);
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTION_FAIL));
		}
		
		protected function handleWebSocketIOError(event:IOErrorEvent):void {
			logger.info("IOErrorEvent: " + event.toString());
		}
		
		protected function handleWebSocketAbnormalClose(event:WebSocketErrorEvent):void {
			logger.info("Abnormal Close: " + event.text);
		}
		
		protected function handleWebSocketSecurityError(event:SecurityErrorEvent):void {
			logger.info("SecurityErrorEvent: " + event.toString());
		}
	}
}