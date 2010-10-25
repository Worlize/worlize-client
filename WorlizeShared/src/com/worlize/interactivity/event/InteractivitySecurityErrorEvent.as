package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class InteractivitySecurityErrorEvent extends Event
	{
		public static const SECURITY_ERROR:String = "securityError";
		
		public function InteractivitySecurityErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}