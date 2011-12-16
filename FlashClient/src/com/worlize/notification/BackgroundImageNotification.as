package com.worlize.notification
{
	import com.worlize.model.BackgroundImageInstance;
	
	import flash.events.Event;

	public class BackgroundImageNotification extends Event
	{
		public static const BACKGROUND_INSTANCE_ADDED:String = "newBackgroundInstanceAdded";
		public static const BACKGROUND_INSTANCE_DELETED:String = "backgroundInstanceDeleted";
		public static const BACKGROUND_INSTANCE_UPDATED:String = "backgroundInstanceUpdated";
		
		public var backgroundInstance:BackgroundImageInstance;
		public var deletedInstanceGuid:String;
		public var updatedBackgroundInstanceData:Object;
		public var updatedBackgroundInstanceGuid:String;
		
		public function BackgroundImageNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}