package com.worlize.notification
{
	import flash.events.Event;
	
	public class ConnectionNotification extends Event
	{
		public static const CONNECTION_ESTABLISHED:String = "connectionEstablished";
		public static const DISCONNECTED:String = "disconnected";
		
		public function ConnectionNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}