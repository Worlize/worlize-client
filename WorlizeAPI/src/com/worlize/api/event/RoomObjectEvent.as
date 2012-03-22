package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	
	import flash.events.Event;
	
	public class RoomObjectEvent extends Event
	{
		public static const OBJECT_MOVED:String = "objectMoved";
		public static const OBJECT_RESIZED:String = "objectResized";
		public static const OBJECT_STATE_CHANGED:String = "objectStateChanged";
		
		public var roomObject:RoomObject;
		
		public function RoomObjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var event:RoomObjectEvent = new RoomObjectEvent(type, bubbles, cancelable);
			event.roomObject = roomObject;
			return event;
		}
	}
}