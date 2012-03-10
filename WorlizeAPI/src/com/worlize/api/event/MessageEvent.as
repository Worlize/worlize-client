package com.worlize.api.event
{
	import com.worlize.api.model.RoomObject;
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class MessageEvent extends Event
	{
		public static const MESSAGE_RECEIVED:String = "messageReceived";
		
		public var message:Object;
		public var fromObject:RoomObject;
		public var fromUser:User;
		
		public function MessageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}