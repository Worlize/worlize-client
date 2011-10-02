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
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectProxy;
	
	import spark.collections.SortField;
	
	public class FriendsList extends EventDispatcher
	{
		private static var _instance:FriendsList;
		
		public static const STATE_READY:String = "ready";
		public static const STATE_LOADING:String = "loading";
		
		public static const LIST_PRIORITY_FRIEND_REQUEST:int = 0;
		public static const LIST_PRIORITY_ONLINE_FRIEND:int = 1;
		public static const LIST_PRIORITY_OFFLINE_FRIEND:int = 2;
		public static const LIST_PRIORITY_ONLINE_FACEBOOK_FRIEND:int = 3;
		
		private var _state:String = STATE_READY;
		
		[Bindable]
		public var baseCollection:ArrayList;
		
		[Bindable]
		public var friends:ListCollectionView = new ListCollectionView();
		
		[Bindable]
		public var friendsForFriendsList:ListCollectionView;

		[Bindable]
		public var onlineFriends:ArrayCollection = new ArrayCollection();
		
		private var friendRequestsHeading:ObjectProxy = new ObjectProxy({
			isHeader: true,
			background: 0x2c8a19,
			color: 0xFFFFFF,
			label: "FRIEND REQUESTS",
			count: 0,
			display: false,
			listPriority: LIST_PRIORITY_FRIEND_REQUEST,
			name: '' // because the stupid sort function can't deal with null values...
		});
		
		private var onlineFriendsHeading:ObjectProxy = new ObjectProxy({
			isHeader: true,
			background: 0x3091c3,
			color: 0xFFFFFF,
			label: "ONLINE FRIENDS",
			count: 0,
			display: false,
			listEmptyMessage: "(None of your friends are online.)",
			listPriority: LIST_PRIORITY_ONLINE_FRIEND,
			name: '' // because the stupid sort function can't deal with null values...
		});
		
		private var offlineFriendsHeading:ObjectProxy = new ObjectProxy({
			isHeader: true,
			background: 0x678a9c,
			color: 0xFFFFFF,
			label: "OFFLINE FRIENDS",
			count: 0,
			display: false,
			listPriority: LIST_PRIORITY_OFFLINE_FRIEND,
			name: '' // because the stupid sort function can't deal with null values...
		});
		
		private var onlineFacebookFriendsHeading:ObjectProxy = new ObjectProxy({
			isHeader: true,
			background: 0x3091c3,
			color: 0xFFFFFF,
			label: "ONLINE FACEBOOK FRIENDS",
			count: 0,
			display: false,
			listPriority: LIST_PRIORITY_ONLINE_FACEBOOK_FRIEND,
			name: '' // because the stupid sort function can't deal with null values...
		});
		
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
			
			baseCollection = new ArrayList();
			
			baseCollection.addItem(friendRequestsHeading);
			baseCollection.addItem(onlineFriendsHeading);
			baseCollection.addItem(offlineFriendsHeading);
			baseCollection.addItem(onlineFacebookFriendsHeading);
			
			initializeFriendsForFriendsListView();
			initializeFriendsView();
			
			applySortAndFilters();
			
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_ACCEPTED, handleFriendRequestAccepted);
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_REJECTED, handleFriendRequestRejected);
			
			load();
		}
		
		private function initializeFriendsForFriendsListView():void {
			friendsForFriendsList = new ListCollectionView();
			friendsForFriendsList.list = baseCollection;
			
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('listPriority'),
				new SortField('isHeader', true),
				new SortField('name')
			];
			friendsForFriendsList.sort = sort;
			
			friendsForFriendsList.filterFunction = function(item:Object):Boolean {
				if (item is FriendsListEntry || item is PendingFriendsListEntry) {
					return true;
				}
				else if (item.isHeader) {
					return ((item.display as Boolean) || item.listEmptyMessage != null);
				}
				return false;
			};
			
			friendsForFriendsList.refresh();
		}
		
		private function initializeFriendsView():void {
			friends = new ListCollectionView();
			friends.list = baseCollection;
			
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('listPriority'),
				new SortField('name')
			];
			friends.sort = sort;
			
			friends.filterFunction = function(item:Object):Boolean {
				if (item is FriendsListEntry) {
					return true
				}
				return false;
			};
			
			friends.refresh();
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
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is FriendsListEntry) {
					if (FriendsListEntry(entry).guid === guid) {
						return FriendsListEntry(entry);
					}					
				}
			}
			return null;
		}
		
		public function removeFriendFromListByGuid(guid:String):void {
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is FriendsListEntry) {
					if (FriendsListEntry(entry).guid === guid) {
						baseCollection.removeItemAt(i);
						applySortAndFilters();
						return;
					}					
				}
			}
		}
		
		private function handleFriendRequestAccepted(notification:FriendsNotification):void {
			load();
		}
		
		private function handleFriendRequestRejected(notification:FriendsNotification):void {
			load();
		}
		
		public function applySortAndFilters():void {
			onlineFriendsHeading['count'] = 0;
			offlineFriendsHeading['count'] = 0;
			onlineFacebookFriendsHeading['count'] = 0;
			friendRequestsHeading['count'] = 0;
			
			for (var i:int=0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is FriendsListEntry) {
					if (FriendsListEntry(entry).online) {
						onlineFriendsHeading['count'] ++;
					}
					else {
						offlineFriendsHeading['count'] ++;
					}
				}
				else if (entry is PendingFriendsListEntry) {
					friendRequestsHeading['count'] ++;
				}
				else {
					// a heading
				}
			}
			
			onlineFriendsHeading['display'] = (onlineFriendsHeading['count'] > 0);
			offlineFriendsHeading['display'] = (offlineFriendsHeading['count'] > 0);
			onlineFacebookFriendsHeading['display'] = (onlineFacebookFriendsHeading['count'] > 0);
			friendRequestsHeading['display'] = (friendRequestsHeading['count'] > 0);
		}
		
		protected function disableAutoUpdate():void {
			friendsForFriendsList.disableAutoUpdate();
		}
		
		protected function enableAutoUpdate():void {
			friendsForFriendsList.enableAutoUpdate();
		}
		
		public function load():void {
			state = STATE_LOADING;
			var index:int;
			var i:int;
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				
				if (event.resultJSON.success) {
					disableAutoUpdate();
					
					var seenGuids:Object = {};
					
					for each (var friendData:Object in event.resultJSON.data.friends) {
						seenGuids[friendData.guid] = true;
						var entry:FriendsListEntry = getFriendsListEntryByGuid(friendData.guid);
						if (entry) {
							entry.updateFromData(friendData);
						}
						else {
							entry = FriendsListEntry.fromData(friendData);
							baseCollection.addItem(entry);
						}
					}
					
					// Remove any unknown items from the old list
					for (i=0; i < baseCollection.length; i++) {
						friendData = baseCollection.getItemAt(i);
						if (friendData is FriendsListEntry) {
							if (!seenGuids[FriendsListEntry(friendData).guid]) {
								baseCollection.removeItemAt(i);
								i --;
							}
						}
						else if (friendData is PendingFriendsListEntry) {
							baseCollection.removeItemAt(i);
							i --;
						}
					}
					
					for each (var pendingFriendData:Object in event.resultJSON.data.pending_friends) {
						var pendingFriendEntry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(pendingFriendData);
						baseCollection.addItem(pendingFriendEntry);
					}
					
					var completeEvent:FriendsListEvent = new FriendsListEvent(FriendsListEvent.LOAD_COMPLETE);
					dispatchEvent(completeEvent);
					
					enableAutoUpdate();
					
					applySortAndFilters();
				}
				state = STATE_READY;
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an unknown error while loading the friends list.", "Error");
				state = STATE_READY;
			});
			var params:Object = {};
			var accessToken:String = ExternalInterface.call('FB.getAccessToken');
			if (accessToken) {
				params['access_token'] = accessToken;
			}
			client.send('/friends.json', HTTPMethod.GET, params);
		}	
	}
}