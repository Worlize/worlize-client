package com.worlize.notification
{
	import flash.events.Event;
	
	public class WorlizeNotification extends Event
	{
		public static const FOCUS_CHAT_BOX_NOTIFICATION:String = "focusChatBoxNotification";
		
		public function WorlizeNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}