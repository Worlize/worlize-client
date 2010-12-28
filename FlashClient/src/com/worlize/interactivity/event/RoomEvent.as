package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	import com.worlize.interactivity.model.InteractivityUser;

	public class RoomEvent extends Event
	{
		public var user:InteractivityUser;
		
		public static const USER_ENTERED:String = "userEntered";
		public static const USER_LEFT:String = "userLeft";
		public static const ROOM_CLEARED:String = "roomCleared";
		public static const USER_MOVED:String = "userMoved";
		public static const SELECTED_USER_CHANGED:String = "selectedUserChanged";
		
		public function RoomEvent(type:String, user:InteractivityUser = null)
		{
			this.user = user;
			super(type, false, false);
		}
		
	}
}