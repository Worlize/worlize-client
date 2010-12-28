package com.worlize.event
{
	import flash.events.Event;
	
	public class AvatarEvent extends Event
	{
		public static const AVATAR_LOADED:String = "avatarLoaded";
		public static const AVATAR_ERROR:String = "avatarError";
		
		public function AvatarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}