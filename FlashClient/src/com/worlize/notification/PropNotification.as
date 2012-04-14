package com.worlize.notification
{
	import com.worlize.model.PropInstance;
	
	import flash.events.Event;
	
	public class PropNotification extends Event
	{
		public static const PROP_INSTANCE_ADDED:String = "propInstanceAdded";
		public static const PROP_INSTANCE_DELETED:String = "propInstanceDeleted";
		
		public var propInstance:PropInstance;
		public var deletedInstanceGuid:String;
		
		public function PropNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}