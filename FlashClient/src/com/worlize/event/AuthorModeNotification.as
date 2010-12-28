package com.worlize.event
{
	import flash.events.Event;
	
	import com.worlize.interactivity.model.Hotspot;
	
	public class AuthorModeNotification extends Event
	{
		public static const AUTHOR_ENABLED:String = "authorEnabled";
		public static const AUTHOR_DISABLED:String = "authorDisabled";
		
		public static const SELECTED_ITEM_CHANGED:String = "selectedItemChanged";
		
		public var newValue:Object;
		public var oldValue:Object;
		
		public function AuthorModeNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}