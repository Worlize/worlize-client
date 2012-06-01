package com.worlize.interactivity.event
{
	import com.worlize.interactivity.model.IRoomItem;
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
		
		public static const APP_STATE_CHANGED:String = "appStateChanged";
		
		public static const ITEM_ADDED:String = "itemAdded";
		public static const ITEM_REMOVED:String = "itemRemoved";
		public static const ITEM_MOVED:String = "itemMoved";
		public static const ITEM_RESIZED:String = "itemResized";
		public static const ITEM_DEST_CHANGED:String = "itemDestChanged";
		
		public var user:InteractivityUser;
		
		public var roomItem:IRoomItem;
		public var appInstance:AppInstance;
		
		public function RoomEvent(type:String, user:InteractivityUser = null)
		{
			this.user = user;
			super(type, false, false);
		}
		
		override public function clone():Event {
			var event:RoomEvent = new RoomEvent(type, user);
			event.roomItem = roomItem;
			event.appInstance = appInstance;
			event.user = user;
			return event;
		}
		
	}
}