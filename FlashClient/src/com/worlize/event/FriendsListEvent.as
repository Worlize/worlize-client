package com.worlize.event
{
	import flash.events.Event;
	
	public class FriendsListEvent extends Event
	{
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		public function FriendsListEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}