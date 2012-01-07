package com.worlize.interactivity.event
{
	import flash.events.Event;

	public class AvatarSelectEvent extends Event
	{
		public static const AVATAR_SELECT:String = "avatarSelect";
		public static const SHOW_CONTEXT_MENU:String = "showContextMenu";
		
		public var userId:String;
		
		public function AvatarSelectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}