package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class ChatEvent extends Event
	{
		public static const INCOMING_CHAT:String = "incomingChat";
		public static const OUTGOING_CHAT:String = "outgoingChat";
		
		// Is this a whisper?
		public var isWhisper:Boolean;
		
		// The intended whisper recipient
		public var recipient:User;
		
		// Who is speaking
		public var user:User;
		
		// Chat text
		public var text:String;
		
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var event:ChatEvent = new ChatEvent(type, bubbles, cancelable);
			event.isWhisper = isWhisper;
			event.recipient = recipient;
			event.user = user;
			event.text = text;
			return event;
		}
	}
}