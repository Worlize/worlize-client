package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class WorlizeVideoEvent extends Event
	{
		public static const STOPPED:String = "stopped";
		public static const STARTED:String = "started";
		
		public function WorlizeVideoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}