package com.worlize.model
{
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.utils.UIDUtil;

	[Bindable]
	public class FriendsListEntry
	{
		public static const TYPE_FACEBOOK:String = "facebook";
		public static const TYPE_WORLIZE:String = "worlize";
		
		public var username:String;
		public var guid:String;
		public var online:Boolean;
		public var facebookProfile:String;
		public var facebookId:String;
		public var twitterProfile:String;
		public var currentRoomGuid:String;
		public var friendType:String;
		public var name:String;
		public var picture:String;
		public var worldEntrance:String;
		
		public static function fromData(data:Object):FriendsListEntry {
			var instance:FriendsListEntry = new FriendsListEntry();
			instance.username = data.username;
			instance.guid = data.guid;
			instance.online = data.online;
			instance.facebookProfile = data.facebook_profile;
			instance.facebookId = data.facebook_id;
			instance.twitterProfile = data.twitter_profile;
			instance.currentRoomGuid = data.current_room_guid;
			instance.worldEntrance = data.world_entrance;
			instance.friendType = data.friend_type;
			instance.name = data.name;
			instance.picture = data.picture;
			if (instance.friendType === TYPE_WORLIZE) {
				instance.name = instance.username;
			}
			return instance;
		}
		
		public function updateFromData(data:Object):void {
			this.username = data.username;
			this.guid = data.guid;
			this.online = data.online;
			this.worldEntrance = data.world_entrance;
		}
		
		public function toString():String {
			return username;
		}
		
		public function unfriend():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					FriendsList.getInstance().removeFriendFromListByGuid(guid);
				}
				else {
					Alert.show("There was an unknown error when attempting to unfriend '" + username + "'");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encoutered when attempting to unfriend '" + username + "'");
			});
			client.send("/friends/" + guid + ".json", HTTPMethod.DELETE);
		}
		
		public function requestToJoin():void {
			var requestToken:String = UIDUtil.createUID();
			FriendsList.getInstance().registerInvitationToken(requestToken);
			
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotification = new VisualNotification(
						"You have requested permission to join " + username + " at their current location.",
						"Request Sent"
					);
					notification.show();
				}
				else {
					Alert.show("There was an unknown error when attempting to request permission to join '" + username + "'");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered when attempting to request permission to join '" + username + "'");
			});
			client.send("/friends/" + guid + "/request_to_join.json", HTTPMethod.POST, {
				invitation_token: requestToken
			});
		}
		
		public function invite():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotification = new VisualNotification(
						"You have invited " + username + " to join you.",
						"Invitation Sent"
					);
					notification.show();
				}
				else {
					Alert.show("There was an unknown error when attempting to invite '" + username + "'");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered when attempting to invite '" + username + "'");
			});
			client.send("/friends/" + guid + "/invite_to_join.json", HTTPMethod.POST);
		}
		
		public function grantPermissionToJoin(invitationToken:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotification = new VisualNotification(
						"You have granted permission to " + username + " to join you at your current location.",
						"Permission Granted"
					);
					notification.show();
				}
				else {
					Alert.show("There was an unknown error when attempting to grant permission to join '" + username + "'");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered when attempting to grant permission to join '" + username + "'");
			});
			client.send("/friends/" + guid + "/grant_permission_to_join.json", HTTPMethod.POST, {
				invitation_token: invitationToken
			});
		}
	}
}