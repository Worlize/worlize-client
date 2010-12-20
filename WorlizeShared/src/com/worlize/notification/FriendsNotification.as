package com.worlize.notification
{
	import flash.events.Event;
	
	public class FriendsNotification extends Event
	{
		public static const FRIEND_REQUEST_ACCEPTED:String = "friendRequestAccepted";
		public static const FRIEND_REQUEST_REJECTED:String = "friendRequestRejected";
		
		public var userGuid:String;
		
		public function FriendsNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}