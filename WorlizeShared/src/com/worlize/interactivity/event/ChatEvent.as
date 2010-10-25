package com.worlize.interactivity.event
{
	import flash.events.Event;
	
	import com.worlize.interactivity.model.InteractivityUser;

	public class ChatEvent extends Event
	{
		public var chatText:String;
		public var logText:String;
		public var user:InteractivityUser;
		public var soundName:String;
		public var whisper:Boolean;
		public var logOnly:Boolean = false;
		
		public static const CHAT:String = "chat";
		public static const WHISPER:String = "whisper";
		public static const ROOM_MESSAGE:String = "roomMessage";
		
		public function ChatEvent(type:String, chatText:String, user:InteractivityUser = null)
		{
			logText = chatText;
			
			var match:Array;
			if (chatText.charAt(0) == ';' || chatText.charAt(0) == "%") {
				logOnly = true;
			}
			
			match = chatText.match(/^\s*(@\d+,\d+){0,1}\s*\)([^\s]+)\s*(.*)$/);
			if (match && match.length > 1) {
				soundName = match[2];
				chatText = "";
				if (match[1]) {
					chatText += match[1];
				}
				if (match[3]) {
					chatText += match[3];
				}
			}
			
			this.chatText = chatText;
			this.user = user;
			this.whisper = Boolean(type == WHISPER);
			super(type, false, true);
		}
		
	}
}