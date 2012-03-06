package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	
	import flash.events.Event;
	
	public class RoomObjectEvent extends Event
	{
		public static const MOVED:String = "objectMoved";
		public static const RESIZED:String = "objectResized";
		
		public var roomObject:RoomObject;
		
		public function RoomObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}