package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class WorlizeCommEvent extends Event
	{
		public static const MESSAGE:String = "message";
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";
		public static const CONNECTION_FAIL:String = "connectionFail";
		
		public var message:Object;
		
		public function WorlizeCommEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}