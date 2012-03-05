package com.worlize.interactivity.api.event
{
	import flash.events.Event;
	
	public class APIBridgeEvent extends Event
	{
		public var data:Object;
		
		public function APIBridgeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}