package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class WorlizeCommEvent extends Event
	{
		public static const MESSAGE:String = "message";
		public static const CONNECTING:String = "connecting";
		public static const CONNECTED:String = "connected";
		public static const DISCONNECTED:String = "disconnected";
		public static const CONNECTION_FAIL:String = "connectionFail";
		
		public static const STATE_CHANGE:String = "stateChange";
		
		public var message:Object;
				
		public var previousState:String;
		public var newState:String;
		
		public function WorlizeCommEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var event:WorlizeCommEvent = new WorlizeCommEvent(type, bubbles, cancelable);
			event.message = message;
			event.previousState = previousState;
			event.newState = newState;
			return event;
		}
	}
}