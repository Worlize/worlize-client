package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	public class UserSelectedEvent extends Event
	{
		public var userID:int = -1;
		public function UserSelectedEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super("userSelected", bubbles, cancelable);
		}
	}
}