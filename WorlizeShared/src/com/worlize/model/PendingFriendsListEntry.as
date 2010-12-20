package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class PendingFriendsListEntry
	{
		public var userName:String;
		public var guid:String;
		public var mutualFriends:ArrayCollection = new ArrayCollection();
		
		public static function fromData(data:Object):PendingFriendsListEntry {
			var instance:PendingFriendsListEntry = new PendingFriendsListEntry();
			instance.userName = data.username;
			instance.guid = data.guid;
			for each (var mutualFriendData:Object in data.mutual_friends) {
				var mutualFriend:FriendsListEntry = new FriendsListEntry();
				mutualFriend.userName = mutualFriendData.username;
				mutualFriend.guid = mutualFriendData.guid;
				instance.mutualFriends.addItem(mutualFriend);
			}
			return instance;
		}
		
		public function toString():String {
			return userName;
		}
		
		public function get capitalizedUsername():String {
			var result:String = userName.charAt(0).toLocaleUpperCase();
			result += userName.slice(1).toLocaleLowerCase();
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
				Alert.show("There was an known error while rejecting the pending friend request from " + userName);
			});
			client.send("/friends/" + guid + "/reject_friendship", HTTPMethod.POST);
		}
		public function acceptFriendShip():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REQUEST_ACCEPTED);
				notification.userGuid = guid;
				NotificationCenter.postNotification(notification);
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an known error while accepting the pending friend request from " + userName);
			});
			client.send("/friends/" + guid + "/accept_friendship", HTTPMethod.POST);
		}
	}
}