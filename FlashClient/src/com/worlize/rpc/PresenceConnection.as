package com.worlize.rpc
{
	import com.worlize.model.WorlizeConfig;
	
	import flash.events.IEventDispatcher;
	
	import mx.logging.Log;
	
	public class PresenceConnection extends WebSocketConnection
	{
		protected var config:WorlizeConfig = WorlizeConfig.getInstance();
		
		public function PresenceConnection(target:IEventDispatcher=null)
		{
			logger = Log.getLogger('com.worlize.rpc.PresenceConnection')
			super(target);
		}
		
		override public function get url():String {
			var url:String = config.useTLS ? 'wss://' : 'ws://';
			url += (config.hostname + ":" + config.port + "/presence/?session=" + config.interactivitySession.sessionGuid);
			return url;
		}
		
		override public function get protocol():String {
			return 'worlize-presence';
		}
	}
}