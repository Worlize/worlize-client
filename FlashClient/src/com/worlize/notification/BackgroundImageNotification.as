package com.worlize.notification
{
	import com.worlize.model.BackgroundImageInstance;
	
	import flash.events.Event;

	public class BackgroundImageNotification extends Event
	{
		public static const BACKGROUND_UPLOADED:String = "newBackgroundUploaded";
		public static const BACKGROUND_INSTANCE_DELETED:String = "backgroundInstanceDeleted";
		
		public var backgroundInstance:BackgroundImageInstance;
		public var deletedInstanceGuid:String;
		
		public function BackgroundImageNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}