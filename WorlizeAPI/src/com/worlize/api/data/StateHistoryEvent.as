package com.worlize.api.data
{
	
	import flash.events.Event;
	
	public class StateHistoryEvent extends Event
	{
		public static const ITEM_ADDED:String = "itemAdded";
		public static const ITEM_REMOVED:String = "itemRemoved";
		public static const CLEARED:String = "cleared";
		
		public var item:StateHistoryEntry;
		public var index:int;
		public var userGuid:String;
		
		public function StateHistoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}