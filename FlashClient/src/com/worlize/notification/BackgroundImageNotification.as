package com.worlize.notification
{
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.RoomListEntry;
	
	import flash.events.Event;

	public class BackgroundImageNotification extends Event
	{
		public static const BACKGROUND_INSTANCE_ADDED:String = "newBackgroundInstanceAdded";
		public static const BACKGROUND_INSTANCE_DELETED:String = "backgroundInstanceDeleted";
		public static const BACKGROUND_INSTANCE_UPDATED:String = "backgroundInstanceUpdated";
		public static const BACKGROUND_INSTANCE_USED:String = "backgroundInstanceUsed";
		public static const BACKGROUND_INSTANCE_UNUSED:String = "backgroundInstanceUnused";
		
		public var room:RoomListEntry;
		public var backgroundInstance:BackgroundImageInstance;
		public var instanceGuid:String;
		public var updatedBackgroundInstanceData:Object;
		public var updatedBackgroundInstanceGuid:String;
		
		public function BackgroundImageNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}