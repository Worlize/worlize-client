package com.worlize.model
{
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	
	public class FriendsList extends EventDispatcher
	{
		private static var _instance:FriendsList;
		
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		
		[Bindable]
		public var state:String = STATE_READY; 
		
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
			if (_instance !== null) {
				throw new Error("You may only create one instance of FriendsList");
			}
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_ACCEPTED, handleFriendRequestAccepted);
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_REJECTED, handleFriendRequestRejected);
		}
		
		private function handleFriendRequestAccepted(notification:FriendsNotification):void {
			load();
		}
		
		private function handleFriendRequestRejected(notification:FriendsNotification):void {
			load();
		}
		
		private function compareValues(a:Object, b:Object):int {
			if (a == null && b == null)
				return 0;
			
			if (a == null)
				return 1;
			
			if (b == null)
				return -1;
			
			if (a is String && b is String) {
				a = String(a).toLocaleUpperCase();
				b = String(b).toLocaleUpperCase();
			}
			
			if (a < b)
				return -1;
			
			if (a > b)
				return 1;
			
			return 0;
		}
		
		private function compareFunction(a:Object, b:Object, fields:Array = null):int {
			var result:int = 0;
			var i:int = 0;
			var propList:Array = fields ? fields : ['userName'];
			var len:int = propList.length;
			var propName:String;
			
			if (a is PendingFriendsListEntry && b is FriendsListEntry) {
				return -1;
			}
			else if (a is FriendsListEntry && b is PendingFriendsListEntry) {
				return 1;
			}
			
			while (result == 0 && (i < len))
			{
				propName = propList[i];
				result = compareValues(a[propName], b[propName]);
				i++;
			}
			return result;
		}
		
		public function load():void {
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					friends.removeAll();
					for each (var friendData:Object in event.resultJSON.data.friends) {
						var entry:FriendsListEntry = FriendsListEntry.fromData(friendData);
						friends.addItem(entry);
					}
					for each (var pendingFriendData:Object in event.resultJSON.data.pending_friends) {
						var pendingFriendEntry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(pendingFriendData);
						friends.addItem(pendingFriendEntry);
					}
					var sort:Sort = new Sort();
					sort.compareFunction = compareFunction;
					friends.sort = sort;
					friends.refresh();
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while loading the friends list.", "Error");
				state = STATE_READY;
			});
			client.send('/friends', HTTPMethod.GET);
		}	
	}
}