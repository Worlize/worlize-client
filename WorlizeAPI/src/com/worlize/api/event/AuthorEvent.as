package com.worlize.api.event
{
	import flash.events.Event;
	
	public class AuthorEvent extends Event
	{
		public static const AUTHOR_MODE_ENABLED:String = "authorModeEnabled";
		public static const AUTHOR_MODE_DISABLED:String = "authorModeDisabled";
		
		public function AuthorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}