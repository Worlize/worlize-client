package com.worlize.event
{
	import flash.events.Event;
	
	public class APIEvent extends Event
	{
		public static const INIT:String = "init";
		
		public function APIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}