package com.worlize.model
{
	import com.worlize.event.FriendsListEvent;
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
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	
	public class FriendsList extends EventDispatcher
	{
		private static var _instance:FriendsList;
		
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		
		private var _state:String = STATE_READY;
		
		[Bindable(event="stateChange")]
		public function set state(newValue:String):void {
			if (_state !== newValue) {
				_state = newValue;
				dispatchEvent(new FlexEvent('stateChange'));
			}
		}
		public function get state():String {
			return _state;
		}
		
		[Bindable]
		public var friends:ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var friendRequests:ArrayCollection = new ArrayCollection();
		
		
		private var invitationTokens:Object = {};
		
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
			
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('online', false, true),
				new SortField('username', true)
			];
			friends.sort = sort;
			
			sort = new Sort();
			sort.fields = [
				new SortField('username', true)
			];
			friendRequests.sort = sort;
			
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_ACCEPTED, handleFriendRequestAccepted);
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_REJECTED, handleFriendRequestRejected);
			
			load();
		}
		
		/* Invitation tokens prevent someone from wisking you away
		   to a place of their choosing if you didn't request to join them
		*/
		public function registerInvitationToken(token:String):void {
			invitationTokens[token] = true;
		}
		
		public function consumeInvitationToken(token:String):void {
			delete invitationTokens[token];
		}
		
		public function invitationTokenIsValid(token:String):Boolean {
			if (invitationTokens[token]) {
				return true;
			}
			return false;
		}
		
		public function getFriendsListEntryByGuid(guid:String):FriendsListEntry {
			for (var i:int = 0; i < friends.length; i++) {
				var entry:Object = friends.getItemAt(i);
				if (FriendsListEntry(entry).guid == guid) {
					return FriendsListEntry(entry);
				}
			}
			return null;
		}
		
		public function removeFriendFromListByGuid(guid:String):void {
			for (var i:int = 0; i < friends.length; i++) {
				var entry:FriendsListEntry = FriendsListEntry(friends.getItemAt(i));
				if (entry.guid == guid) {
					friends.removeItemAt(i);
					return;
				}
			}
		}
		
		private function handleFriendRequestAccepted(notification:FriendsNotification):void {
			load();
		}
		
		private function handleFriendRequestRejected(notification:FriendsNotification):void {
			load();
		}
		
		public function load():void {
			state = STATE_LOADING;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var seenGuids:Object = {};
					
					for each (var friendData:Object in event.resultJSON.data.friends) {
						seenGuids[friendData.guid] = true;
						var entry:FriendsListEntry = getFriendsListEntryByGuid(friendData.guid);
						if (entry) {
							entry.updateFromData(friendData);
						}
						else {
							entry = FriendsListEntry.fromData(friendData);
							friends.addItem(entry);
						}
					}
					
					// Remove any unknown items from the old list
					for each (friendData in friends) {
						if (!seenGuids[FriendsListEntry(friendData).guid]) {
							var index:int = friends.getItemIndex(friendData);
							if (index != -1) {
								friends.removeItemAt(index);
							}
						}
					}
					
					friendRequests.removeAll();
					for each (var pendingFriendData:Object in event.resultJSON.data.pending_friends) {
						var pendingFriendEntry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(pendingFriendData);
						friendRequests.addItem(pendingFriendEntry);
					}
					friends.refresh();
					friendRequests.refresh();
					var completeEvent:FriendsListEvent = new FriendsListEvent(FriendsListEvent.LOAD_COMPLETE);
					dispatchEvent(completeEvent);
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while loading the friends list.", "Error");
				state = STATE_READY;
			});
			client.send('/friends.json', HTTPMethod.GET);
		}	
	}
}