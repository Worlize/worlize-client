package com.worlize.model
{
	import com.worlize.control.Marketplace;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.SystemManager;
	import com.worlize.rpc.WorlizeServiceClient;
	
	public class WorlizeConfig extends EventDispatcher
	{
		private static var _instance:WorlizeConfig;
		
		public var interactivitySession:InteractivitySession;
		public var currentUser:CurrentUser = CurrentUser.getInstance();
		
		public var hostname:String;
		public var port:uint;
		public var useTLS:Boolean = false;
		
		public function WorlizeConfig(target:IEventDispatcher=null)
		{
			super(target);
			if (_instance !== null) {
				throw new Error("You may only create one instance of WorlizeComm");
			}
		}
		
		public static function getInstance():WorlizeConfig {
			if (!_instance) {
				_instance = new WorlizeConfig();
				_instance.initJavascriptWrapper();
			}
			return _instance;
		}
		
		protected function initJavascriptWrapper():void {
			var config:Object = ExternalInterface.call('configData');
			if (config) {
				hostname = config.interactivity_hostname;
				port = config.interactivity_port;
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