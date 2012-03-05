package com.worlize.api.event
{
	import flash.events.Event;
	
	public class ChangeEvent extends Event
	{
		public static const UPDATED:String = "updated";
		public static const DELETED:String = "deleted";
		
		public var key:String;
		public var newValue:*;
		public var oldValue:*;
		
		public function ChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}