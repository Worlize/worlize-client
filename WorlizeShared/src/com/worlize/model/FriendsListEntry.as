package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import mx.controls.Alert;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;

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
	}
}