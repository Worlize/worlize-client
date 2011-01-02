package com.worlize.model.gifts
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.UserListEntry;
	import com.worlize.notification.GiftNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;

	[Bindable]
	public class Gift
	{
		public static const STATE_LOADING:String = "loading";
		public static const STATE_NEW:String = "new";
		public static const STATE_ACCEPTED:String = "accepted";
		public static const STATE_REJECTED:String = "rejected";
		
		public var guid:String;
		public var type:String; // One of the constants from GiftType
		public var sender:UserListEntry;
		public var note:String;
		public var thumbnailURL:String;
		public var itemGuid:String;
		public var state:String = STATE_NEW;
		public var item:Object; // The actual item
		
		public static function fromData(data:Object):Gift {
			var instance:Gift = new Gift();
			instance.guid = data.guid;
			instance.type = data.type;
			instance.note = data.note;
			
			var sender:UserListEntry = new UserListEntry();
			sender = new UserListEntry();
			sender.userGuid = data.sender.guid;
			sender.username = data.sender.username;
			instance.sender = sender;
			
			switch (instance.type) {
				case GiftType.AVATAR:
					instance.thumbnailURL = data.item.thumbnail;
					instance.itemGuid = data.item.guid;
					break;
				default:
					throw new Error("Gift type " + instance.type + " not supported.");
					break;
			}
			
			return instance;
		}
		
		public function acceptGift():void {
			var gift:Gift = this;
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					state = STATE_ACCEPTED;
					item = event.resultJSON.data;
					var notification:GiftNotification = new GiftNotification(GiftNotification.GIFT_ACCEPTED);
					notification.gift = gift;
					NotificationCenter.postNotification(notification);
				}
				else {
					state = STATE_NEW;
					Alert.show(event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				state = STATE_NEW;
				Alert.show("There was a fault encountered when accepting your gift.", "Error");
			});
			client.send("/gifts/" + guid + "/accept.json", HTTPMethod.POST);
		}
		
		public function rejectGift():void {
			var gift:Gift = this;
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					state = STATE_REJECTED;
					var notification:GiftNotification = new GiftNotification(GiftNotification.GIFT_REJECTED);
					notification.gift = gift;
					NotificationCenter.postNotification(notification);
				}
				else {
					state = STATE_NEW;
					Alert.show("There was an error when ignoring your gift: " + event.resultJSON.description, "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				state = STATE_NEW;
				Alert.show("There was a fault encountered when ignoring your gift.", "Error");
			});
			client.send("/gifts/" + guid + ".json", HTTPMethod.DELETE);
		}
	}
}
