package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class UserEvent extends Event
	{
		public static const MOVED:String = "userMoved";
		public static const AVATAR_CHANGED:String = "userAvatarChanged";
		public static const FACE_CHANGED:String = "userFaceChanged";
		public static const COLOR_CHANGED:String = "userColorChanged";
		public static const CAN_AUTHOR_CHANGED:String = "userCanAuthorChanged";
		
		public var user:User;
		
		public function UserEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			var e:UserEvent = new UserEvent(type, bubbles, cancelable);
			e.user = user;
			return e;
		}
		
		override public function toString():String {
			return "[UserEvent type=" + type + " target=" + target + " user: " + user + "]";
		}
	}
}