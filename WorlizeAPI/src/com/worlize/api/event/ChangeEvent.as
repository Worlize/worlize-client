package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class ChangeEvent extends Event
	{
		public static const PROPERTY_CHANGED:String = "propertyChanged";
		public static const PROPERTY_DELETED:String = "propertyDeleted";
		
		public var name:String;
		public var changedBy:User;
		public var newValue:*;
		public var oldValue:*;
		
		public function ChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}