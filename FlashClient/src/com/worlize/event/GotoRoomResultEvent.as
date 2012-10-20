package com.worlize.event
{
	import com.worlize.model.InteractivitySession;
	
	import flash.events.Event;
	
	public class GotoRoomResultEvent extends Event
	{
		public static const GOTO_ROOM_RESULT:String = "gotoRoomResult";
		
		public var success:Boolean;
		public var failureReason:String;
		public var interactivitySession:InteractivitySession;
		
		public function GotoRoomResultEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}