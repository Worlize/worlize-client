package com.worlize.components.visualnotification
{
	import flash.events.Event;
	
	public class VisualNotificationEvent extends Event
	{
		public static const SHOW_NOTIFICATION:String = "showNotificaton";
		public static const HIDE_NOTIFICATION:String = "hideNotification"; 
		
		public var notification:VisualNotificationRequest;
		
		public function VisualNotificationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}