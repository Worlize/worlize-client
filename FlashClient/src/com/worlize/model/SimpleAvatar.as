package com.worlize.model
{
	import com.worlize.command.DeleteAvatarInstanceCommand;
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.model.gifts.IGiftable;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import com.worlize.model.friends.FriendsListEntry;

	[Event(name="avatarLoaded",type="com.worlize.event.AvatarEvent")]
	[Event(name="avatarError",type="com.worlize.event.AvatarEvent")]
	
	[Bindable]
	public class SimpleAvatar extends EventDispatcher implements IGiftable
	{
		public var name:String;
		public var ready:Boolean = false;
		public var guid:String;
		public var creatorGuid:String;
		public var thumbnailURL:String;
		public var fullsizeURL:String;
		public var mediumURL:String;
		public var smallURL:String;
		public var tinyURL:String;
		public var error:Boolean = false;
		
		public function fromData(data:Object):void {
			name = data.name;
			guid = data.guid;
			creatorGuid = data.creator_guid;
			fullsizeURL = data.fullsize;
			mediumURL = data.medium;
			smallURL = data.small;
			tinyURL = data.tiny;
			thumbnailURL = data.thumbnail;
			ready = true;
		}
		
		public static function fromData(data:Object):SimpleAvatar {
			var avatarDefinition:SimpleAvatar = new SimpleAvatar();
			avatarDefinition.fromData(data);
			return avatarDefinition;
		}
		
		public function sendAsGift(recipient:FriendsListEntry, callback:Function=null):void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					callback(false, event.resultJSON);
				}
				else {
					callback(true, event.resultJSON);
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				callback(true, null);
				Alert.show("There was a fault encountered while attempting to send a gift to " + recipient.username + ".", "Error");
			});
			client.send("/avatars/" + guid + "/send_as_gift.json", HTTPMethod.POST, {
				recipient_guid: recipient.guid
			});
		}
	}
}