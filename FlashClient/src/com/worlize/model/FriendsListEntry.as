package com.worlize.model
{
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	import mx.utils.UIDUtil;

	[Bindable]
	public class FriendsListEntry
	{
		public static const TYPE_FACEBOOK:String = "facebook";
		public static const TYPE_WORLIZE:String = "worlize";
		
		public var listPriority:int = -1;
		public var isHeader:Boolean = false;
		
		private var _online:Boolean;
		
		public var username:String;
		public var guid:String;
		public var facebookProfile:String;
		public var facebookId:String;
		public var twitterProfile:String;
		public var currentRoomGuid:String;
		public var friendType:String;
		public var name:String;
		public var picture:String;
		public var worldEntrance:String;
		
		[Bindable(event="onlineChanged")]
		public function set online(newValue:Boolean):void {
			var changed:Boolean = false;
			if (_online !== newValue) {
				changed = true;
				_online = newValue;
			}
			listPriority = (_online) ? FriendsList.LIST_PRIORITY_ONLINE_FRIEND : FriendsList.LIST_PRIORITY_OFFLINE_FRIEND;
			if (changed) {
				var event:FlexEvent = new FlexEvent('onlineChanged');
				dispatchEvent(event);
			}
		}
		public function get online():Boolean {
			return _online;
		}
		
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
			this.facebookProfile = data.facebook_profile;
			this.facebookId = data.facebook_id;
			this.twitterProfile = data.twitter_profile;
			this.currentRoomGuid = data.current_room_guid;
			this.worldEntrance = data.world_entrance;
			this.friendType = data.friend_type;
			this.name = data.name;
			this.picture = data.picture;
			if (this.friendType === TYPE_WORLIZE) {
				this.name = this.username;
			}
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