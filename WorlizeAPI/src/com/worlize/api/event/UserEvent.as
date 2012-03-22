package com.worlize.api.event
{
	import com.worlize.api.model.User;
	
	import flash.events.Event;
	
	public class UserEvent extends Event
	{
		public static const USER_MOVED:String = "userMoved";
		public static const USER_AVATAR_CHANGED:String = "userAvatarChanged";
		public static const USER_FACE_CHANGED:String = "userFaceChanged";
		public static const USER_COLOR_CHANGED:String = "userColorChanged";
		public static const USER_PRIVILEGES_CHANGED:String = "userPrivilegesChanged";
		
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