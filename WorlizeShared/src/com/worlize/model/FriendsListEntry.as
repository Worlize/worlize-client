package com.worlize.model
{
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.components.visualnotification.VisualNotificationRequest;
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
		public var username:String;
		public var guid:String;
		public var online:Boolean;
		public var worldEntrance:String;
		
		public static function fromData(data:Object):FriendsListEntry {
			var instance:FriendsListEntry = new FriendsListEntry();
			instance.username = data.username;
			instance.guid = data.guid;
			instance.online = data.online;
			instance.worldEntrance = data.world_entrance;
			return instance;
		}
		
		public function toString():String {
			return username;
		}
		
		public function unfriend():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					FriendsList.getInstance().load();
				}
				else {
					Alert.show("There was an unknown error when attempting to unfriend '" + username + "'");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encoutered when attempting to unfriend '" + username + "'");
			});
			client.send("/friends/" + guid, HTTPMethod.DELETE);
		}
		
		public function requestToJoin():void {
			var requestToken:String = UIDUtil.createUID();
			FriendsList.getInstance().registerInvitationToken(requestToken);
			
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotificationRequest = new VisualNotificationRequest(
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
			client.send("/friends/" + guid + "/request_to_join", HTTPMethod.POST, {
				invitation_token: requestToken
			});
		}
		
		public function invite():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotificationRequest = new VisualNotificationRequest(
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
			client.send("/friends/" + guid + "/invite_to_join", HTTPMethod.POST);
		}
		
		public function grantPermissionToJoin(invitationToken:String):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotificationRequest = new VisualNotificationRequest(
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
			client.send("/friends/" + guid + "/grant_permission_to_join", HTTPMethod.POST, {
				invitation_token: invitationToken
			});
		}
	}
}