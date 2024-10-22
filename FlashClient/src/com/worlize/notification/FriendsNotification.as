package com.worlize.notification
{
	import com.worlize.model.friends.FriendsListEntry;
	
	import flash.events.Event;
	
	public class FriendsNotification extends Event
	{
		public static const FRIEND_REQUEST_ACCEPTED:String = "friendRequestAccepted";
		public static const FRIEND_REQUEST_REJECTED:String = "friendRequestRejected";
		public static const FRIEND_REMOVED:String = "friendRemoved";
		public static const FRIEND_ADDED:String = "friendAdded";
		public static const FRIEND_UPDATED:String = "friendUpdated";
		
		public var userGuid:String;
		public var friendsListEntry:FriendsListEntry;
		
		
		public function FriendsNotification(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}