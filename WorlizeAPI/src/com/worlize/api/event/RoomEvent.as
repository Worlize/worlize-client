package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class RoomEvent extends Event
	{
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const OBJECT_ADDED:String = "objectAdded";
		public static const OBJECT_REMOVED:String = "objectRemoved";
		
		public var user:User;
		
		public function RoomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var event:RoomEvent = new RoomEvent(type, bubbles, cancelable);
			event.user = user;
			return event;
		}
		
		override public function toString():String {
			return "[RoomEvent type=" + type + " target=" + target + " user: " + user + "]";
		}
	}
}