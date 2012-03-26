package com.worlize.interactivity.api.event
{
	import flash.events.Event;
	
	public class AppLoaderEvent extends Event
	{
		public static const APP_BOMBED:String = "appBombed";
		public static const HANDSHAKE_COMPLETE:String = "handshakeComplete";
		
		public function AppLoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}