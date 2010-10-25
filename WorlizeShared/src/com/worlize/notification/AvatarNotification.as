package com.worlize.notification
{
	import com.worlize.model.AvatarInstance;
	
	import flash.events.Event;
	
	public class AvatarNotification extends Event
	{
		public static const AVATAR_UPLOADED:String = "newAvatarUploaded";
		public static const AVATAR_INSTANCE_DELETED:String = "avatarInstanceDeleted";
		
		public var avatarInstance:AvatarInstance;
		public var deletedInstanceGuid:String;
		
		public function AvatarNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}