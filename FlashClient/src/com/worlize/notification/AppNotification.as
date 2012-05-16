package com.worlize.notification
{
	import com.worlize.model.AppInstance;
	import com.worlize.model.RoomListEntry;
	
	import flash.events.Event;
	
	public class AppNotification extends Event
	{
		public static const APP_INSTANCE_ADDED:String = "appInstanceAdded";
		public static const APP_INSTANCE_DELETED:String = "appInstanceDeleted";
		public static const APP_INSTANCE_ADDED_TO_ROOM:String = "appInstanceAddedToRoom";
		public static const APP_INSTANCE_REMOVED_FROM_ROOM:String = "appInstanceRemovedFromRoom";
		
		public var appInstance:AppInstance;
		public var room:RoomListEntry;
		public var instanceGuid:String;
		
		public function AppNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}