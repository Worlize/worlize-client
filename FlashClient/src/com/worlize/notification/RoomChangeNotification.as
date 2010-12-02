package com.worlize.notification
{
	import flash.events.Event;
	
	public class RoomChangeNotification extends Event
	{
		public static const ROOM_DELETED:String = "roomDeleted";
		
		public var roomGuid:String;
		
		public function RoomChangeNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}