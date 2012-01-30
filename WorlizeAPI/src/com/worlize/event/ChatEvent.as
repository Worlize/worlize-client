package com.worlize.event
{
	import com.worlize.model.User;
	
	import flash.events.Event;
	
	public class ChatEvent extends Event
	{
		public static const INCOMING_CHAT:String = "incomingChat";
		public static const OUTGOING_CHAT:String = "outgoingChat";
		
		// Is this a whisper?
		public var isWhisper:Boolean;
		
		// The intended whisper recipient
		public var whisperTarget:User;
		
		// Who is speaking
		public var user:User;
		
		// Chat text
		public var text:String;
		
		public function ChatEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}