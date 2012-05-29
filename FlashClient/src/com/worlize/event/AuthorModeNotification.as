package com.worlize.event
{
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.IRoomItem;
	import com.worlize.model.InWorldObjectInstance;
	
	import flash.events.Event;
	
	public class AuthorModeNotification extends Event
	{
		public static const AUTHOR_ENABLED:String = "authorEnabled";
		public static const AUTHOR_DISABLED:String = "authorDisabled";
		
		public static const EDIT_MODE_ENABLED:String = "editModeEnabled";
		public static const EDIT_MODE_DISABLED:String = "editModeDisabled";
		
		public static const SELECTED_ITEM_CHANGED:String = "selectedItemChanged";
		
		public var newValue:Object;
		public var oldValue:Object;
		
		public var roomItem:IRoomItem;
		
		public function AuthorModeNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}