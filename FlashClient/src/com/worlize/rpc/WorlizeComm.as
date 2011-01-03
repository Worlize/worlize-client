package com.worlize.rpc
{
	import com.adobe.protocols.dict.events.ConnectedEvent;
	import com.adobe.serialization.json.JSON;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InteractivitySession;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="message")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="connected")]
	[Event(type="com.worlize.interactivity.event.WorlizeCommEvent",name="disconnected")]
	public class WorlizeComm extends EventDispatcher
	{
		private static var _instance:WorlizeComm;
		
		public var interactivitySession:InteractivitySession;
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
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
			ExternalInterface.call('worlizeSend', encodeURIComponent(JSON.encode(message)));
		}
		
		public function connect():void {
			ExternalInterface.call('worlizeConnect', interactivitySession.serverId);
		}
		
		public function disconnect():void {
			ExternalInterface.call('worlizeDisconnect');
		}
		
		protected function initJavascriptWrapper():void {
			ExternalInterface.addCallback('handleMessage', handleMessage);
			ExternalInterface.addCallback('handleConnect', handleConnect);
			ExternalInterface.addCallback('handleDisconnect', handleDisconnect);
			ExternalInterface.call('worlizeInitialize');
			var config:Object = ExternalInterface.call('configData');
			if (config) {
				interactivitySession = InteractivitySession.fromData(config.interactivity_session);
				WorlizeServiceClient.authenticityToken = config.authenticity_token;
				WorlizeServiceClient.cookies = config.cookies;
				currentUser.load(config.user_guid);
			}
//			trace("User Guid: " + interactivitySession.userGuid);
//			trace("Session Guid: " + interactivitySession.sessionGuid);
//			trace("Cookies: " + JSON.encode(config.cookies));
		}
		
		private function handleMessage(message:String):void {
			var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
			try {
				event.message = JSON.decode(decodeURIComponent(message));
			}
			catch (e:Error) {
				event.message = null;
			}
			dispatchEvent(event);
		}
		
		private function handleConnect():void {
			var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.CONNECTED);
			dispatchEvent(event);
		}
		
		private function handleDisconnect():void {
			var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.DISCONNECTED);
			dispatchEvent(event);
		}
	}
}