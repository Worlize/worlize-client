package com.worlize.model
{
	import com.worlize.model.friends.FriendsListEntry;
	import com.worlize.model.gifts.IGiftable;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class Prop implements IGiftable
	{
		public var name:String;
		public var guid:String;
		public var imageURL:String;
		public var mediumURL:String;
		public var thumbnailURL:String;
		public var creatorGuid:String;
		
		// not yet used
		public var offsetX:int = 0;
		public var offsetY:int = 0;
		public var width:int = 0;
		public var height:int = 0;
		
		public static function fromData(data:Object):Prop {
			var prop:Prop = new Prop();
			prop.name = data.name;
			prop.guid = data.guid;
			prop.imageURL = data.image;
			prop.thumbnailURL = data.thumbnail;
			prop.mediumURL = data.medium;
			prop.creatorGuid = data.creator_guid;
			return prop;
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
			client.send("/props/" + guid + "/send_as_gift.json", HTTPMethod.POST, {
				recipient_guid: recipient.guid
			});
		}
	}
}