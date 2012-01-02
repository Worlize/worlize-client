package com.worlize.interactivity.event
{
	import com.worlize.interactivity.model.ChatBubbleStyle;
	import com.worlize.interactivity.model.InteractivityUser;
	
	import flash.events.Event;

	public class ChatEvent extends Event
	{
		public var chatText:String;
		public var logText:String;
		public var x:int = 0;
		public var y:int = 0;
		public var locationSet:Boolean = false;
		public var user:InteractivityUser;
		public var soundName:String;
		public var bubbleStyle:String;
		public var whisper:Boolean;
		public var logOnly:Boolean;
		
		public static const CHAT:String = "chat";
		public static const WHISPER:String = "whisper";
		public static const ROOM_MESSAGE:String = "roomMessage";
		
		private static const locationRegExp:RegExp = /^\@([\d]+)[, ]([\d]+)\s*(.*)$/;
		private static const soundRegExp:RegExp = /^\)([^\s]+)\s*(.*)$/;
		
		public function ChatEvent(type:String, text:String, user:InteractivityUser = null)
		{
			logText = chatText = text;
			
			// Find bubble coordinates
			var match:Array = text.match(locationRegExp);
			if (match && match.length > 3) {
				locationSet = true;
				x = parseInt(match[1], 10);
				y = parseInt(match[2], 10);
				chatText = match[3];
			}
			
			// Find chat bubble style
			if (chatText) {
				switch (chatText.charAt(0)) {
					case '^':
						logOnly = false;
						bubbleStyle = ChatBubbleStyle.STICKY;
						chatText = chatText.slice(1);
						break;
					case '!':
						logOnly = false;
						bubbleStyle = ChatBubbleStyle.EXCLAMATION;
						chatText = chatText.slice(1);
						break;
					case ':':
						logOnly = false;
						bubbleStyle = ChatBubbleStyle.THOUGHT;
						chatText = chatText.slice(1);
						break;
					case '%':
					case ';':
						logOnly = true;
						bubbleStyle = ChatBubbleStyle.CHAT;
						chatText = chatText.slice(1);
						break;
					default:
						logOnly = false;
						bubbleStyle = ChatBubbleStyle.CHAT;
						break;
				}
			}
			
			// Find any sound to play
			match = chatText.match(soundRegExp);
			if (match && match.length > 1) {
				soundName = match[1];
				if (match[2]) {
					chatText = match[2];
				}
			}
			
			if (logOnly) {
				chatText = "";
			}
			
			this.user = user;
			this.whisper = Boolean(type == WHISPER);
			super(type, false, true);
		}
		
	}
}