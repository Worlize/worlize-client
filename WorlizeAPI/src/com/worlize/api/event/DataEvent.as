package com.worlize.api.event
{
	import flash.events.Event;
	
	public class DataEvent extends Event
	{
		public static const ITEM_ADDED:String = "itemAdded";
		public static const ITEM_REMOVED:String = "itemRemoved";
		
		public var item:*;
		public var index:int;
		
		public function DataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}