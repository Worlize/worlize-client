package com.worlize.api.data
{
	
	import flash.events.Event;
	
	public class StateHistoryEvent extends Event
	{
		public static const ENTRY_ADDED:String = "entryAdded";
		public static const ENTRY_REMOVED:String = "entryRemoved";
		public static const CLEARED:String = "cleared";
		
		public var entry:Object;
		public var index:int;
		
		public function StateHistoryEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}