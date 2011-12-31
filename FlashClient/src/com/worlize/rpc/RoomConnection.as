package com.worlize.rpc
{
	import com.worlize.model.WorlizeConfig;
	
	import flash.events.IEventDispatcher;
	
	import mx.logging.Log;

	public class RoomConnection extends WebSocketConnection
	{
		protected var config:WorlizeConfig = WorlizeConfig.getInstance();
		
		public function RoomConnection(target:IEventDispatcher=null)
		{
			logger = Log.getLogger('com.worlize.rpc.RoomConnection')
			super(target);
		}
		
		override public function get url():String {
			var url:String = config.useTLS ? 'wss://' : 'ws://';
			url += (config.hostname + ":" + config.port + "/" + config.interactivitySession.serverId + "/?session=" + config.interactivitySession.sessionGuid);
			return url;
		}
		
		override public function get protocol():String {
			return 'worlize-interact';
		}
	}
}