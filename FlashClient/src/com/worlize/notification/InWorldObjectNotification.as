package com.worlize.notification
{
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.RoomListEntry;
	
	import flash.events.Event;
	
	public class InWorldObjectNotification extends Event
	{
		public static const IN_WORLD_OBJECT_INSTANCE_ADDED:String = "inWorldObjectInstanceAdded";
		public static const IN_WORLD_OBJECT_INSTANCE_DELETED:String = "inWorldObjectInstanceDeleted";
		public static const IN_WORLD_OBJECT_ADDED_TO_ROOM:String = "inWorldObjectAddedToRoom";
		public static const IN_WORLD_OBJECT_REMOVED_FROM_ROOM:String = "inWorldObjectRemovedFromRoom";
		
		public var inWorldObjectInstance:InWorldObjectInstance;
		public var room:RoomListEntry;
		public var instanceGuid:String;
		
		public function InWorldObjectNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}