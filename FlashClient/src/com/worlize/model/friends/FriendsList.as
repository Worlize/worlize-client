package com.worlize.model.friends
{
	import com.adobe.serialization.json.JSON;
	import com.worlize.event.FriendsListEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.ListCollectionView;
	import mx.collections.Sort;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
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
		
		private var updateOnlineFacebookFriendsTimer:Timer = new Timer(7000, 0);
		
		[Bindable]
		public var baseCollection:ArrayList;
		
		[Bindable]
		public var friendsForFriendsList:ListCollectionView;

		[Bindable]
		public var friends:ListCollectionView;
		
		[Bindable]
		public var onlineFriends:ListCollectionView;
		
		[Bindable]
		public var friendRequests:ListCollectionView;
		
		private var queuedPresenceStatusChanges:Array = [];
		
		private var friendRequestsHeading:ObjectProxy = new ObjectProxy({
			selectionEnabled: false,
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
			selectionEnabled: false,
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
			selectionEnabled: false,
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
			selectionEnabled: false,
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
				if (_state === STATE_READY) {
					processQueuedPresenceStatusChanges();
				}
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
			initializeOnlineFriendsView();
			initializeFriendRequestsView();
			
			updateHeadingCounts();
			
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_ACCEPTED, handleFriendRequestAccepted);
			NotificationCenter.addListener(FriendsNotification.FRIEND_REQUEST_REJECTED, handleFriendRequestRejected);
			
			// TODO: Can't use the native direct FQL query for online users yet.
			// Have to resolve the integer overflow issue first.
			updateOnlineFacebookFriendsTimer.addEventListener(TimerEvent.TIMER, handleOnlineFacebookFriendsTimer);
//			updateOnlineFacebookFriendsTimer.start();
			
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
				if (item is FriendsListEntry ||
					item is PendingFriendsListEntry ||
					item is OnlineFacebookFriend)
				{
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
		
		private function initializeOnlineFriendsView():void {
			onlineFriends = new ListCollectionView();
			onlineFriends.list = baseCollection;
			
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('name')
			];
			onlineFriends.sort = sort;
			
			onlineFriends.filterFunction = function(item:Object):Boolean {
				if (item is FriendsListEntry && (item as FriendsListEntry).online) {
					return true
				}
				return false;
			};
			
			onlineFriends.refresh();
		}
		
		private function initializeFriendRequestsView():void {
			friendRequests = new ListCollectionView();
			friendRequests.list = baseCollection;
			
			var sort:Sort = new Sort();
			sort.fields = [
				new SortField('name')
			];
			friendRequests.sort = sort;
			
			friendRequests.filterFunction = function(item:Object):Boolean {
				if (item is PendingFriendsListEntry) {
					return true;
				}
				return false;
			};
			
			friendRequests.refresh();
		}
		
		protected function disableAutoUpdate():void {
			friendsForFriendsList.disableAutoUpdate();
			friends.disableAutoUpdate();
			onlineFriends.disableAutoUpdate();
			friendRequests.disableAutoUpdate();
		}
		
		protected function enableAutoUpdate():void {
			friendsForFriendsList.enableAutoUpdate();
			friends.enableAutoUpdate();
			onlineFriends.enableAutoUpdate();
			friendRequests.enableAutoUpdate();
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
		
		public function updateFriendStatus(friendGuid:String, newStatus:String):void {
			// If the main friends list is loading when we receive a change and
			// we drop it on the floor, the presence status in the friends list
			// will be stale.  Therefore, we queue up changes if the friends
			// list is still loading and apply them after the loading is
			// complete.
			queuedPresenceStatusChanges.push({
				friendGuid: friendGuid,
				newStatus: newStatus
			});
			if (state === STATE_READY) {
				processQueuedPresenceStatusChanges();
			}
		}
		
		private function processQueuedPresenceStatusChanges():void {
			for each (var change:Object in queuedPresenceStatusChanges) {
				var friend:FriendsListEntry = getFriendsListEntryByGuid(change.friendGuid);
				if (friend) {
					try {
						friend.presenceStatus = change.newStatus;
					}
					catch(e:Error) {
						// unsupported presence status.
						trace(e);
					}
				}
			}
			queuedPresenceStatusChanges = [];
			updateHeadingCounts();
		}
		
		public function getFriendsListEntryByGuid(guid:String):FriendsListEntry {
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is FriendsListEntry) {
					if (FriendsListEntry(entry).guid === guid) {
						return entry as FriendsListEntry;
					}					
				}
			}
			return null;
		}
		
		public function getOnlineFacebookFriendById(id:String):OnlineFacebookFriend {
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is OnlineFacebookFriend) {
					return entry as OnlineFacebookFriend;
				}
			}
			return null;
		}
		
		public function addFriendsListEntry(entry:FriendsListEntry):void {
			baseCollection.addItem(entry);
			updateHeadingCounts();
		}
		
		public function removeFriendFromListByGuid(guid:String):void {
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is FriendsListEntry) {
					if (FriendsListEntry(entry).guid === guid) {
						baseCollection.removeItemAt(i);
						updateHeadingCounts();
						return;
					}					
				}
			}
		}
		
		public function removeFriendRequestFromListByGuid(guid:String):void {
			for (var i:int = 0; i < baseCollection.length; i++) {
				var entry:Object = baseCollection.getItemAt(i);
				if (entry is PendingFriendsListEntry) {
					if (PendingFriendsListEntry(entry).guid === guid) {
						baseCollection.removeItemAt(i);
						updateHeadingCounts();
						return;
					}					
				}
			}
		}
		
		private function handleFriendRequestAccepted(notification:FriendsNotification):void {
			addFriendsListEntry(notification.friendsListEntry);
			removeFriendRequestFromListByGuid(notification.friendsListEntry.guid);
		}
		
		private function handleFriendRequestRejected(notification:FriendsNotification):void {
			removeFriendRequestFromListByGuid(notification.userGuid);
		}
		
		public function updateHeadingCounts():void {
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
				else if (entry is OnlineFacebookFriend) {
					onlineFacebookFriendsHeading['count'] ++;
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
						else if (friendData is OnlineFacebookFriend) {
							baseCollection.removeItemAt(i);
							i --;
						}
					}
					
					for each (var pendingFriendData:Object in event.resultJSON.data.pending_friends) {
						var pendingFriendEntry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(pendingFriendData);
						baseCollection.addItem(pendingFriendEntry);
					}
					
					for each (var onlineFacebookFriendData:Object in event.resultJSON.data.online_facebook_friends) {
						var onlineFacebookFriend:OnlineFacebookFriend = OnlineFacebookFriend.fromData(onlineFacebookFriendData);
						baseCollection.addItem(onlineFacebookFriend);
					}
					
					var completeEvent:FriendsListEvent = new FriendsListEvent(FriendsListEvent.LOAD_COMPLETE);
					dispatchEvent(completeEvent);
					
					enableAutoUpdate();
					
					updateHeadingCounts();
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
		
		private function handleOnlineFacebookFriendsTimer(event:TimerEvent):void {
			loadOnlineFacebookFriends();
		}
		
		public function loadOnlineFacebookFriends():void {
			var accessToken:String = ExternalInterface.call('FB.getAccessToken');
			if (accessToken === null) {
				return;
			}
			
			var service:HTTPService = new HTTPService();
			service.url = 'https://api.facebook.com/method/fql.query';
			service.addEventListener(ResultEvent.RESULT, handleOnlineFacebookFriendsResult);
			service.addEventListener(FaultEvent.FAULT, handleOnlineFacebookFriendsFault);
			service.resultFormat = 'text';
			service.send({
				access_token: accessToken,
				format: 'json',
				query: 'SELECT uid, name, pic_square, online_presence ' +
					   'FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me()) ' +
					   'ORDER BY uid'
			});
		}
		
		private function handleOnlineFacebookFriendsResult(event:ResultEvent):void {
			trace("Got friends result!");
			// TODO: Fixme... the UID field is overflowing AS3's 32-bit int datatype.
			var resultJSON:Object = JSON.decode(event.result as String);
			
			if (resultJSON) {
				disableAutoUpdate();
				
				var seenIds:Object = [];
				for each (var friendData:Object in resultJSON) {
					if (friendData.online_presence === 'active') {
						seenIds[friendData.uid] = true;
						var f:OnlineFacebookFriend = getOnlineFacebookFriendById(friendData.uid);
						if (f) {
							f.updateFromData(friendData);
						}
						else {
							f = OnlineFacebookFriend.fromData(friendData);
							baseCollection.addItem(f);
						}
					}
				}
				
				// Remove any unknown items from the old list
				for (var i:int=0; i < baseCollection.length; i++) {
					friendData = baseCollection.getItemAt(i);
					if (friendData is OnlineFacebookFriend) {
						if (!seenIds[friendData.facebookId]) {
							baseCollection.removeItemAt(i);
							i --;
						}
					}
				}
				
				updateHeadingCounts();
				enableAutoUpdate();
			}
		}
		
		private function handleOnlineFacebookFriendsFault(event:FaultEvent):void {
			trace("Online Facebook Friends Fault");
		}
	}
}