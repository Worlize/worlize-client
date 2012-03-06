package com.worlize.interactivity.event
{
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.Event;

	public class RoomEvent extends Event
	{
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const ROOM_CLEARED:String = "roomCleared";
		public static const USER_MOVED:String = "userMoved";
		public static const SELECTED_USER_CHANGED:String = "selectedUserChanged";
		
		public static const OBJECT_ADDED:String = "objectAdded";
		public static const OBJECT_REMOVED:String = "objectRemoved";
		public static const OBJECT_MOVED:String = "objectMoved";
		public static const OBJECT_RESIZED:String = "objectResized";
		
		public var user:InteractivityUser;
		public var roomObject:InWorldObjectInstance;
		
		public function RoomEvent(type:String, user:InteractivityUser = null)
		{
			this.user = user;
			super(type, false, false);
		}
		
		override public function clone():Event {
			var event:RoomEvent = new RoomEvent(type, user);
			event.roomObject = roomObject;
			return event;
		}
		
	}
}