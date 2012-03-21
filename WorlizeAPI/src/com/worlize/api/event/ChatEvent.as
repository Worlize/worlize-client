package com.worlize.api.event
{
	import com.worlize.api.model.User;
	import com.worlize.worlize_internal;
	
	import flash.events.Event;
	
	public class ChatEvent extends Event
	{
		use namespace worlize_internal;
		
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
		
		
		// Original, unmodified chat text
		public var originalText:String;
		
		public function ChatEvent(type:String) {
			super(type, false, true);
		}
		
		override public function clone():Event {
			var event:ChatEvent = new ChatEvent(type);
			event.isWhisper = isWhisper;
			event.text = text;
			event.originalText = originalText;
			event.recipient = recipient;
			event.user = user;
			return event;
		}
	}
}