package com.worlize.model.friends
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class PendingFriendsListEntry
	{
		private var _username:String;
		
		public var listPriority:int = FriendsList.LIST_PRIORITY_FRIEND_REQUEST;
		public var isHeader:Boolean = false;
		
		public var online:Boolean = false;
		public var guid:String;
		public var picture:String;
		
		public static function fromData(data:Object):PendingFriendsListEntry {
			var instance:PendingFriendsListEntry = new PendingFriendsListEntry();
			instance.username = data.username;
			instance.guid = data.guid;
			instance.picture = data.picture;
			return instance;
		}
		
		public function toString():String {
			return username;
		}
		
		[Bindable(event='usernameChange')]
		public function set username(newValue:String):void {
			if (_username != newValue) {
				_username = newValue;
				dispatchEvent(new FlexEvent('usernameChange'));
			}
		}
		public function get username():String {
			return _username;
		}
		
		// 'name' must be included because the sort functions used in the
		// friends list cannot deal with non-null values.  It throws a bizarre
		// error if one of the entries has a null value.
		[Bindable(event='usernameChange')]
		public function get name():String {
			return _username;
		}
		
		[Bindable(event='usernameChange')]
		public function get capitalizedUsername():String {
			var result:String = _username.charAt(0).toLocaleUpperCase();
			result += _username.slice(1).toLocaleLowerCase();
			return result;
		}
		
		public function rejectFriendship():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REQUEST_REJECTED);
					notification.userGuid = event.resultJSON.friend_guid;
					NotificationCenter.postNotification(notification);					
				}
				else {
					Alert.show("There was an unknown error while rejecting the pending friend request from " + username);
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while rejecting the pending friend request from " + username);
			});
			client.send("/friends/" + guid + "/reject_friendship.json", HTTPMethod.POST);
		}
		public function acceptFriendShip():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REQUEST_ACCEPTED);
					notification.friendsListEntry = FriendsListEntry.fromData(event.resultJSON.friends_list_entry);
					notification.userGuid = guid;
					NotificationCenter.postNotification(notification);
				}
				else {
					Alert.show("There was an unknown error while accepting the pending friend request from " + username);
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while accepting the pending friend request from " + username);
			});
			client.send("/friends/" + guid + "/accept_friendship.json", HTTPMethod.POST);
		}
	}
}