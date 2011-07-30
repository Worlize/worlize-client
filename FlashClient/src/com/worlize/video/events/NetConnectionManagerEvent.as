package com.worlize.video.events
{
	import flash.events.Event;
	
	public class NetConnectionManagerEvent extends Event
	{
		public static const CONNECTING:String = "connecting";
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTING:String = "disconnecting";
		public static const DISCONNECTED:String = "disconnected";
		public static const RECONNECTING:String = "reconnecting";
		
		public function NetConnectionManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}