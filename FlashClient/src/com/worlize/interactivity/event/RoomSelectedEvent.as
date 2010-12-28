package com.worlize.interactivity.event
{
	import flash.events.Event;

	public class RoomSelectedEvent extends Event
	{
		public var roomID:String = null;
		public function RoomSelectedEvent(bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super("roomSelected", bubbles, cancelable);
		}
		
	}
}