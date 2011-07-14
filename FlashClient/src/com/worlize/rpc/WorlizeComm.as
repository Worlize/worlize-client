package com.worlize.rpc
{
	import com.adobe.protocols.dict.events.ConnectedEvent;
	import com.adobe.serialization.json.JSON;
	import com.wirelust.as3zlib.System;
	import com.worlize.control.Marketplace;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InteractivitySession;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.SystemManager;
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	public class WorlizeComm extends EventDispatcher
	{
		private static var _instance:WorlizeComm;
		
		public var interactivitySession:InteractivitySession;
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var hostname:String;
		public var port:uint;
		public var useTLS:Boolean = false;
		
		private var webSocket:WebSocket;
		
		public function WorlizeComm(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one instance of WorlizeComm");
			}
		}
		
		public static function getInstance():WorlizeComm {
			if (!_instance) {
				_instance = new WorlizeComm();
				_instance.initJavascriptWrapper();
			}
			return _instance;
		}
		
		public function send(message:Object):void {
			webSocket.sendUTF(JSON.encode(message));
		}
		
		public function connect():void {
			ExternalInterface.call('worlizeConnect', interactivitySession.serverId);
			
			var url:String = useTLS ? 'wss://' : 'ws://';
			url += (hostname + ":" + port + "/" + interactivitySession.serverId + "/");
			
			// Disable logger
			WebSocket.debug = false;
			
			webSocket = new WebSocket(url, FlexGlobals.topLevelApplication.url, 'worlize-interact');
			webSocket.enableDeflateStream = true;
			webSocket.connect();
			
			webSocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			webSocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			webSocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			webSocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleWebSocketConnectionFail);
			webSocket.addEventListener(IOErrorEvent.IO_ERROR, handleWebSocketIOError);
			webSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleWebSocketSecurityError);
		}
		
		private function handleWebSocketOpen(event:WebSocketEvent):void {
			trace("WebSocket: Connection Opened");
			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.CONNECTED));
		}
		private function handleWebSocketClosed(event:WebSocketEvent):void {
			trace("WebSocket: Connection Closed");
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
			trace("WebSocket: Connection Fail");
//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		private function handleWebSocketIOError(event:IOErrorEvent):void {
			trace("WebSocket: IOErrorEvent");
//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		private function handleWebSocketSecurityError(event:SecurityErrorEvent):void {
			trace("WebSocket: SecurityErrorEvent");
//			dispatchEvent(new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED));
		}
		
		public function disconnect():void {
			webSocket.close();
		}
		
		protected function initJavascriptWrapper():void {
			var config:Object = ExternalInterface.call('configData');
			if (config) {
				hostname = config.interactivity_hostname;
				port = parseInt(config.interactivity_port, 10);
				useTLS = config.interactivity_tls;
				interactivitySession = InteractivitySession.fromData(config.interactivity_session);
				WorlizeServiceClient.authenticityToken = config.authenticity_token;
				WorlizeServiceClient.cookies = config.cookies;
				currentUser.load(config.user_guid);
				Marketplace.marketplaceEnabled = config.marketplace_enabled;
			}
//			trace("User Guid: " + interactivitySession.userGuid);
//			trace("Session Guid: " + interactivitySession.sessionGuid);
//			trace("Cookies: " + JSON.encode(config.cookies));
		}
	}
}