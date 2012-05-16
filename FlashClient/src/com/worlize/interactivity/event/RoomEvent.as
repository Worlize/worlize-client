package com.worlize.interactivity.event
{
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.model.AppInstance;
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.Event;

	public class RoomEvent extends Event
	{
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const ROOM_CLEARED:String = "roomCleared";
		public static const USER_MOVED:String = "userMoved";
		public static const SELECTED_USER_CHANGED:String = "selectedUserChanged";
		
		public static const APP_ADDED:String = "appAdded";
		public static const APP_REMOVED:String = "appRemoved";
		public static const APP_MOVED:String = "appMoved";
		public static const APP_RESIZED:String = "appResized";
		public static const APP_STATE_CHANGED:String = "appStateChanged";
		
		public var user:InteractivityUser;
		public var roomObject:InWorldObjectInstance;
		public var appInstance:AppInstance;
		
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