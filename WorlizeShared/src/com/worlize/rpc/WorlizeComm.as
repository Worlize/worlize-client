package com.worlize.rpc
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.model.InteractivitySession;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import com.worlize.interactivity.event.WorlizeCommEvent;
	
	public class WorlizeComm extends EventDispatcher
	{
		private static var _instance:WorlizeComm;
		
		public var interactivitySession:InteractivitySession;
		
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
			ExternalInterface.call('worlizeSend', message);
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
			}
			trace("User Guid: " + interactivitySession.userGuid);
			trace("Session Guid: " + interactivitySession.sessionGuid);
			trace("Cookies: " + JSON.encode(config.cookies));
		}
		
		private function handleMessage(message:Object):void {
			var event:WorlizeCommEvent = new WorlizeCommEvent(WorlizeCommEvent.MESSAGE);
			event.message = message;
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