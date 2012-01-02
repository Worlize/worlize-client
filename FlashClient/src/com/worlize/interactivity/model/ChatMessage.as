package com.worlize.interactivity.model
{
	import com.worlize.interactivity.view.ChatBubble;

	public class ChatMessage
	{
		public var text:String;
		public var isWhisper:Boolean;
		public var x:int;
		public var y:int;
		public var tint:uint;
		public var user:InteractivityUser;
		public var chatBubble:ChatBubble;
		public var bubbleStyle:String = ChatBubbleStyle.CHAT;
		public var displayFailureCount:uint = 0;
		
		public var hideTimeout:uint;
		
		public function ChatMessage()
		{
			
		}
		
		public function get isStickyBubble():Boolean {
			return bubbleStyle === ChatBubbleStyle.STICKY;
		}
	}
}