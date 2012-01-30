package com.worlize.event
{
	import flash.events.Event;
	
	public class RoomEvent extends Event
	{
		public static const USER_ENTER:String = "userEnter";
		public static const USER_LEAVE:String = "userLeave";
		
		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}