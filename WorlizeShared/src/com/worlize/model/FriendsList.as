package com.worlize.model
{
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class FriendsList extends EventDispatcher
	{
		private static var _instance:FriendsList;
		
		[Bindable]
		public var friends:ArrayCollection = new ArrayCollection();
		
		public static function getInstance():FriendsList {
			if (_instance === null) {
				_instance = new FriendsList();
			}
			return _instance;
		}
		
		public function FriendsList(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function load():void {
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					friends.removeAll();
					for each (var friendData:Object in event.resultJSON.data.friends) {
						var entry:FriendsListEntry = FriendsListEntry.fromData(friendData);
						friends.addItem(entry);
					}
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while loading the friends list.", "Error");
			});
			client.send('/friends', HTTPMethod.GET);
		}	
	}
}