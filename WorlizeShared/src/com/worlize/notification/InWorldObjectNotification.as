package com.worlize.notification
{
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.Event;
	
	public class InWorldObjectNotification extends Event
	{
		public static const IN_WORLD_OBJECT_UPLOADED:String = "inWorldObjectUploaded";
		public static const IN_WORLD_OBJECT_DELETED:String = "inWorldObjectDeleted";
		
		public var inWorldObjectInstance:InWorldObjectInstance;
		public var deletedInstanceGuid:String;
		
		public function InWorldObjectNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}