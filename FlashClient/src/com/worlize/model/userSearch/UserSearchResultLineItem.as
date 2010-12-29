package com.worlize.model.userSearch
{
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class UserSearchResultLineItem
	{
		
		public var username:String;
		public var guid:String;
		public var isFriend:Boolean;
		public var hasPendingRequest:Boolean;
		
		public static function fromData(data:Object):UserSearchResultLineItem {
			var instance:UserSearchResultLineItem = new UserSearchResultLineItem();
			instance.username = data.username;
			instance.guid = data.guid;
			instance.isFriend = data.is_friend;
			instance.hasPendingRequest = data.has_pending_request;
			return instance;
		}
		
		public function addAsFriend():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:VisualNotification = new VisualNotification(
						"You have sent a friend request to " + username + ".",
						"Friend Request Sent"
					);
					notification.show();
					hasPendingRequest = true;
				}
				else {
					Alert.show("There was an error while trying to add " + username + " as a friend:\n" + event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was a fault encountered when trying to add " + username + " as a friend.", "Error");
			});
			client.send("/friends/" + guid + "/request_friendship.json", HTTPMethod.POST);
		}
	}
}