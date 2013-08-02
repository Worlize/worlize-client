package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class IgnoredUserEvent extends Event
	{
		public static const USER_IGNORED:String = 'userIgnored';
		public static const USER_UNIGNORED:String = 'userUnignored';
		
		public var userGuid:String;
		
		public function IgnoredUserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}