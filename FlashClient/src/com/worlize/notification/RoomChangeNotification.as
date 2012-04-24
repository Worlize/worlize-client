package com.worlize.notification
{
	import com.worlize.model.RoomListEntry;
	
	import flash.events.Event;
	
	public class RoomChangeNotification extends Event
	{
		public static const ROOM_DELETED:String = "roomDeleted";
		public static const ROOM_ADDED:String = "roomAdded";
		public static const ROOM_UPDATED:String = "roomUpdated";
		
		public var roomGuid:String;
		public var roomListEntry:RoomListEntry;
		public var worldGuid:String;
		
		public function RoomChangeNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}