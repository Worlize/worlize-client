package com.worlize.model
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
		
		public var guid:String;
		public var mutualFriends:ArrayCollection = new ArrayCollection();
		
		public static function fromData(data:Object):PendingFriendsListEntry {
			var instance:PendingFriendsListEntry = new PendingFriendsListEntry();
			instance.username = data.username;
			instance.guid = data.guid;
			for each (var mutualFriendData:Object in data.mutual_friends) {
				var mutualFriend:FriendsListEntry = new FriendsListEntry();
				mutualFriend.username = mutualFriendData.username;
				mutualFriend.guid = mutualFriendData.guid;
				instance.mutualFriends.addItem(mutualFriend);
			}
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
		
		[Bindable(event='usernameChange')]
		public function get capitalizedUsername():String {
			var result:String = _username.charAt(0).toLocaleUpperCase();
			result += _username.slice(1).toLocaleLowerCase();
			return result;
		}
		
		public function rejectFriendship():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REQUEST_REJECTED);
				notification.userGuid = guid;
				NotificationCenter.postNotification(notification);
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an known error while rejecting the pending friend request from " + username);
			});
			client.send("/friends/" + guid + "/reject_friendship.json", HTTPMethod.POST);
		}
		public function acceptFriendShip():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REQUEST_ACCEPTED);
				notification.userGuid = guid;
				NotificationCenter.postNotification(notification);
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an known error while accepting the pending friend request from " + username);
			});
			client.send("/friends/" + guid + "/accept_friendship.json", HTTPMethod.POST);
		}
	}
}