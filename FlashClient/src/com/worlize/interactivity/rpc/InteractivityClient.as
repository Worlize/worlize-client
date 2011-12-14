package com.worlize.interactivity.rpc
{
	import com.adobe.net.URI;
	import com.adobe.serialization.json.JSON;
	import com.worlize.command.GotoRoomCommand;
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.control.VirtualCurrencyProducts;
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.GotoRoomResultEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.event.InteractivityEvent;
	import com.worlize.interactivity.event.InteractivitySecurityErrorEvent;
	import com.worlize.interactivity.event.WebcamBroadcastEvent;
	import com.worlize.interactivity.event.WorlizeCommEvent;
	import com.worlize.interactivity.iptscrae.IptEventHandler;
	import com.worlize.interactivity.iptscrae.IptInteractivityController;
	import com.worlize.interactivity.model.CurrentRoom;
	import com.worlize.interactivity.model.Hotspot;
	import com.worlize.interactivity.model.InteractivityConfig;
	import com.worlize.interactivity.model.InteractivityUser;
	import com.worlize.interactivity.model.RoomHistoryManager;
	import com.worlize.interactivity.model.WebcamBroadcastManager;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.interactivity.view.SoundPlayer;
	import com.worlize.model.AvatarInstance;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.PreferencesManager;
	import com.worlize.model.PublicWorldsList;
	import com.worlize.model.RoomDefinition;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.SimpleAvatarStore;
	import com.worlize.model.UserListEntry;
	import com.worlize.model.VideoAvatar;
	import com.worlize.model.WorldDefinition;
	import com.worlize.model.WorlizeConfig;
	import com.worlize.model.YouTubePlayerDefinition;
	import com.worlize.model.friends.FriendsList;
	import com.worlize.model.friends.FriendsListEntry;
	import com.worlize.model.friends.PendingFriendsListEntry;
	import com.worlize.model.gifts.Gift;
	import com.worlize.model.gifts.GiftsList;
	import com.worlize.model.locker.AvatarLocker;
	import com.worlize.notification.AvatarNotification;
	import com.worlize.notification.BackgroundImageNotification;
	import com.worlize.notification.ConnectionNotification;
	import com.worlize.notification.FinancialNotification;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.notification.RoomChangeNotification;
	import com.worlize.rpc.HTTPMethod;
	import com.worlize.rpc.PresenceConnection;
	import com.worlize.rpc.RoomConnection;
	import com.worlize.rpc.WorlizeConnectionState;
	import com.worlize.rpc.WorlizeResultEvent;
	import com.worlize.rpc.WorlizeServiceClient;
	import com.worlize.state.AuthorModeState;
	import com.worlize.video.control.NetConnectionManager;
	import com.worlize.websocket.WebSocket;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.XMLSocket;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.events.FaultEvent;
	
	import org.openpalace.iptscrae.IptEngineEvent;
	import org.openpalace.iptscrae.IptTokenList;
	
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectStart")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectComplete")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="connectFailed")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="disconnected")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="gotoURL")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="roomChanged")]
	[Event(type="net.codecomposer.event.InteractivityEvent",name="authenticationRequested")]
	[Event(type="net.codecomposer.event.InteractivitySecurityErrorEvent",name="securityError")]
	
	public class InteractivityClient extends EventDispatcher
	{
		
		private static var instance:InteractivityClient;
		
		[Bindable]
		public static var loaderContext:LoaderContext = new LoaderContext();
		
		private var logger:ILogger = Log.getLogger("com.worlize.interactivity.rpc.InteractivityClient");
		
		public var version:int;
		
		public function get id():String {
			return worlizeConfig.interactivitySession.userGuid;
		}
		
		public var serverId:String;
		
		[Bindable]
		public var preferencesManager:PreferencesManager = PreferencesManager.getInstance();
		
		[Bindable]
		public var currentWorld:WorldDefinition = new WorldDefinition();
		[Bindable]
		public var utf8:Boolean = false;
		[Bindable]
		public var port:uint = 0;
		[Bindable]
		public var host:String = null;
		[Bindable]
		public var initialRoom:uint = 0;
		
		private var _roomConnectionState:String = WorlizeConnectionState.CONNECTING;
		[Bindable(event="roomConnectionStateChanged")]
		public function get roomConnectionState():String {
			return _roomConnectionState;
		}
		public function set roomConnectionState(newValue:String):void {
			if (_roomConnectionState !== newValue) {
				_roomConnectionState = newValue;
				dispatchEvent(new FlexEvent("roomConnectionStateChanged"));
			}
		}
		
		[Bindable(event="roomConnectionStateChanged")]
		public function get roomConnected():Boolean {
			return _roomConnectionState === WorlizeConnectionState.CONNECTED;
		}
		
		[Bindable]
		public var currentRoom:CurrentRoom = new CurrentRoom();
		
		[Bindable]
		public var webcamBroadcastManager:WebcamBroadcastManager = new WebcamBroadcastManager();
		
		public var roomById:Object = {};
		
		public var chatstr:String = "";
		public var whochat:String = null;
		public var needToRunSignonHandlers:Boolean = true; 
		
		private var assetRequestQueueTimer:Timer = null;
		private var assetRequestQueue:Array = [];
		private var assetRequestQueueCounter:int = 0;
		private var assetsLastRequestedAt:Date = new Date();
		
		private var chatQueue:Vector.<ChatRecord> = new Vector.<ChatRecord>;
		private var currentChatItem:ChatRecord;
		
		public var cyborgHotspot:Hotspot = new Hotspot();
		
		private var recentLogonUserIds:ArrayCollection = new ArrayCollection();
		
		public var worlizeConfig:WorlizeConfig = WorlizeConfig.getInstance();
		
		[Bindable]
		public var netConnectionManager:NetConnectionManager = new NetConnectionManager();
		
		[Bindable]
		public var iptInteractivityController:IptInteractivityController;
		
		[Bindable]
		public var roomHistoryManager:RoomHistoryManager;
		
		[Bindable]
		public var canAuthor:Boolean = false;
		
		[Bindable]
		public var friendsList:FriendsList = FriendsList.getInstance();
		
		[Bindable]
		public var giftsList:GiftsList = GiftsList.getInstance();
		
		[Bindable]
		public var worldsList:PublicWorldsList = PublicWorldsList.getInstance();
		
		private var expectingDisconnect:Boolean = false;
		
		private var temporaryUserFlags:int;
		// We get the user flags before we have the current user
		
		public var notificationManager:VisualNotificationManager = VisualNotificationManager.getInstance();
		
		public var roomConnection:RoomConnection;
		
		public var presenceConnection:PresenceConnection;
		
		// States
		public static const STATE_DISCONNECTED:int = 0;
		public static const STATE_HANDSHAKING:int = 1;
		public static const STATE_READY:int = 2; 
		
		// Incoming Message Handlers
		private var incomingMessageHandlers:Object = {
			"user_enter": handleUserNew,
			"say": handleReceiveTalk,
			"whisper": handleReceiveWhisper,
			"move": handleMove,
			"set_face": handleUserFace,
			"set_color": handleUserColor,
			"user_leave": handleUserLeaving,
			"room_definition": handleRoomDefinition,
			"global_msg": handleGlobalMessage,
			"new_hotspot": handleNewHotspot,
			"hotspot_moved": handleHotspotMoved,
			"hotspot_removed": handleHotspotRemoved,
			"hotspot_dest_updated": handleHotspotDestUpdated,
			"ping": handlePing,
			"set_simple_avatar": handleSetSimpleAvatar,
			"set_video_avatar": handleSetVideoAvatar,
			"naked": handleNaked,
			"goto_room": handleGotoRoomMessage,
			"room_redirect": handleRoomRedirect,
			"new_object": handleNewObject,
			"object_moved": handleObjectMoved,
			"object_updated": handleObjectUpdated, // dest changed
			"object_removed": handleObjectRemoved,
			"friend_removed": handleFriendRemoved,
			"friend_added": handleFriendAdded,
			"friend_request_accepted": handleFriendRequestAccepted,
			"new_friend_request": handleNewFriendRequest,
			"invitation_to_join_friend": handleInvitationToJoinFriend,
			"request_permission_to_join": handleRequestPermissionToJoin,
			"permission_to_join_granted": handlePermissionToJoinGranted,
			"youtube_player_added": handleYouTubePlayerAdded,
			"youtube_player_moved": handleYouTubePlayerMoved,
			"youtube_player_data_updated": handleYouTubePlayerDataUpdated,
			"youtube_player_removed": handleYouTubePlayerRemoved,
			"youtube_load": handleYouTubeLoad,
			"youtube_pause": handleYouTubePause,
			"youtube_play": handleYouTubePlay,
			"youtube_stop": handleYouTubeStop,
			"youtube_seek": handleYouTubeSeek,
			"gift_received": handleGiftReceived,
			"background_instance_added": handleBackgroundInstanceAdded,
			"avatar_instance_added": handleAvatarInstanceAdded,
			"avatar_instance_deleted": handleAvatarInstanceDeleted,
			"in_world_object_instance_added": handleInWorldObjectInstanceAdded,
			"balance_updated": handleBalanceUpdated,
			"payment_completed": handlePaymentCompleted,
			"set_video_server": handleSetVideoServer,
			"logged_out": handleLoggedOut,
			"presence_status_change": handlePresenceStatusChange
		};
		
		public static function getInstance():InteractivityClient {
			if (InteractivityClient.instance == null) {
				InteractivityClient.instance = new InteractivityClient();
			}
			return InteractivityClient.instance;
		}
		
		public function InteractivityClient()
		{
			if (InteractivityClient.instance != null) {
				throw new Error("Cannot create more than one instance of a singleton.");
			}
			
			roomHistoryManager = new RoomHistoryManager();
			roomHistoryManager.client = this;
			
			iptInteractivityController = new IptInteractivityController();
			iptInteractivityController.client = this;
			
			webcamBroadcastManager.addEventListener(WebcamBroadcastEvent.BROADCAST_START, handleCameraBroadcastStart);
			webcamBroadcastManager.addEventListener(WebcamBroadcastEvent.CAMERA_PERMISSION_REVOKED, handleCameraPermissionRevoked);
			
			currentWorld.load(worlizeConfig.interactivitySession.worldGuid);
			
			ChangeWatcher.watch(this, ['currentWorld', 'ownerGuid'], handleWorldOwnerChange);
		}
		
		private function handleWorldOwnerChange(event:Event):void {
			verifyUserCanAuthor();
		}
		
		private function verifyUserCanAuthor():void {
			canAuthor = (currentWorld.ownerGuid === id);
			if (AuthorModeState.getInstance().enabled && !canAuthor) {
				var authorModeNotificaton:AuthorModeNotification = new AuthorModeNotification(AuthorModeNotification.AUTHOR_DISABLED);
				NotificationCenter.postNotification(authorModeNotificaton);
			}
		}
		
		private function initPresenceConnection():void {
			presenceConnection = new PresenceConnection();
			presenceConnection.addEventListener(WorlizeCommEvent.CONNECTED, handlePresenceConnected);
			presenceConnection.addEventListener(WorlizeCommEvent.DISCONNECTED, handlePresenceDisconnected);
			presenceConnection.addEventListener(WorlizeCommEvent.MESSAGE, handlePresenceMessage);
			presenceConnection.connect();
		}
		
		private function handlePresenceConnected(event:WorlizeCommEvent):void {
			logger.info("Presence Connection Established.");
		}
		
		private function handlePresenceDisconnected(event:WorlizeCommEvent):void {
			showDisconnectedMessage();
		}
		
		private function handlePresenceMessage(event:WorlizeCommEvent):void {
			if (event.message) {
				routeIncomingMessage(event.message);
			}
		}
		
		private function handleConnected(event:WorlizeCommEvent):void {
			logger.info("Room Server Connection Established.");
			roomConnectionState = WorlizeConnectionState.CONNECTED;
			expectingDisconnect = false;
			var connectEvent:InteractivityEvent = new InteractivityEvent(InteractivityEvent.CONNECT_COMPLETE);
			dispatchEvent(connectEvent);
			var notification:ConnectionNotification = new ConnectionNotification(ConnectionNotification.CONNECTION_ESTABLISHED);
			NotificationCenter.postNotification(notification);
			currentRoom.selfUserId = id;
		}
		
		private var disconnectedMessageShowing:Boolean = false;
		private function showDisconnectedMessage():void {
			if (disconnectedMessageShowing) { return; }
			disconnectedMessageShowing = true;
			Alert.show( "The connection to the server has been lost.  Press OK to reconnect.",
				"Connection Lost",
				Alert.OK | Alert.CANCEL,
				null,
				function(event:CloseEvent):void {
					disconnectedMessageShowing = false;
					if (event.detail === Alert.CANCEL) {
						ExternalInterface.call('redirectToHomepage');
						return;
					}
					if (!roomConnected) {
						reconnectToRoomServer();
					}
					if (presenceConnection && !presenceConnection.connected) {
						presenceConnection.connect();
					}
				}
			);
		}
		
		private function handleDisconnected(event:WorlizeCommEvent):void {
			roomConnectionState = WorlizeConnectionState.CLOSED;
			roomConnection.removeEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
			roomConnection.removeEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
			roomConnection.removeEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleRoomConnectionFail);
			roomConnection.removeEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
			roomConnection = null;
			
			if (expectingDisconnect) {
				// do nothing
				logger.info("Disconnected from room server, but was expecting disconnection.");
			}
			else {
				logger.error("Disconnected from room server!");
				resetState();
				var notification:ConnectionNotification = new ConnectionNotification(ConnectionNotification.DISCONNECTED);
				NotificationCenter.postNotification(notification);
				showDisconnectedMessage();
			}
			expectingDisconnect = false;
		}
		
		private function handleRoomConnectionFail(event:WorlizeCommEvent):void {
			expectingDisconnect = true;
			reconnectToRoomServer();
		}
		
		private function handleIncomingMessage(event:WorlizeCommEvent):void {
			if (event.message) {
				routeIncomingMessage(event.message);
			}
		}
		
		private function routeIncomingMessage(message:Object):void {
			if (message && message.msg) {
				var data:Object = null;
				if (message['data']) {
					data = message.data;
				}
				var handlerFunction:Function = incomingMessageHandlers[message.msg];
				if (handlerFunction is Function) {
					handlerFunction(data);
				}
				else {
					logger.warn("Unhandled message: " + JSON.encode(message));
				}
			}
		}
		
		private function handlePresenceStatusChange(data:Object):void {
			if (data.user && data.presence_status) {
				friendsList.updateFriendStatus(data.user, data.presence_status);
			}
		}
		
		private function handleLoggedOut(data:Object):void {
			disconnect();
			var message:String = "You have been logged out.";
			if (data) {
				message = data as String;
			}
			Alert.show(message, "Disconnected", Alert.OK, null, function(event:CloseEvent):void {
				ExternalInterface.call("handleLoggedOut");
			});
		}
		
		private function handleSetVideoServer(data:Object):void {
			netConnectionManager.connect(data as String);
		}
		
		private function handlePaymentCompleted(data:Object):void {
			VirtualCurrencyProducts.hide();
		}
		
		private function handleBalanceUpdated(data:Object):void {
			var user:CurrentUser = CurrentUser.getInstance();
			user.coins = data.coins;
			user.bucks = data.bucks;
			var notification:FinancialNotification = new FinancialNotification(FinancialNotification.FINANCIAL_BALANCE_CHANGE);
			notification.coins = data.coins;
			notification.bucks = data.bucks;
			NotificationCenter.postNotification(notification);
		}
		
		private function handleInWorldObjectInstanceAdded(data:Object):void {
			var inWorldObjectInstance:InWorldObjectInstance = InWorldObjectInstance.fromData(data);
			
			var notification:InWorldObjectNotification = new InWorldObjectNotification(InWorldObjectNotification.IN_WORLD_OBJECT_INSTANCE_ADDED);
			notification.inWorldObjectInstance = inWorldObjectInstance;
			NotificationCenter.postNotification(notification);
		}
		
		private function handleAvatarInstanceAdded(data:Object):void {
			var avatarInstance:AvatarInstance = AvatarInstance.fromData(data);
			
			var notification:AvatarNotification = new AvatarNotification(AvatarNotification.AVATAR_INSTANCE_ADDED);
			notification.avatarInstance = avatarInstance;
			NotificationCenter.postNotification(notification);
		}
		
		private function handleAvatarInstanceDeleted(data:Object):void {
			if (data.guid) {
				// Remove avatar if we're wearing it...
				var currentAvatar:SimpleAvatar = currentUser.simpleAvatar;
				var locker:AvatarLocker = AvatarLocker.getInstance();
				var instance:AvatarInstance = locker.getAvatarInstaceByGuid(data.guid);
				if (instance) {
					if (currentAvatar && currentAvatar.guid == instance.avatar.guid) {
						naked();
					}
				}
				
				var notification:AvatarNotification = new AvatarNotification(AvatarNotification.AVATAR_INSTANCE_DELETED);
				notification.deletedInstanceGuid = data.guid;
				NotificationCenter.postNotification(notification);		
			}
		}
		
		private function handleBackgroundInstanceAdded(data:Object):void {
			var backgroundInstance:BackgroundImageInstance = BackgroundImageInstance.fromData(data);
			var notification:BackgroundImageNotification = new BackgroundImageNotification(BackgroundImageNotification.BACKGROUND_INSTANCE_ADDED);
			notification.backgroundInstance = backgroundInstance;
			NotificationCenter.postNotification(notification);
		}
		
		private function handleGiftReceived(data:Object):void {
			var gift:Gift = Gift.fromData(data.gift);
			GiftsList.getInstance().addGift(gift);
			var message:String;
			if (gift.sender) {
				message = "You've received a gift from " + gift.sender.username + "!  Click \"Gifts\" at the top of the screen to accept it!";
			}
			else {
				message = "You've received a gift!  Click \"Gifts\" at the top of the screen to accept it!";
			}
			var notification:VisualNotification = new VisualNotification(message, "Gift Received!");
			notification.show();
		}
		
		private function handleYouTubePause(data:Object):void {
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player);
			if (player) {
				player.pauseRequested();
			}
		}
		
		private function handleYouTubePlay(data:Object):void {
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player);
			if (player) {
				player.playRequested();
			}
		}
		
		private function handleYouTubeStop(data:Object):void {
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player);
			if (player) {
				player.stopRequested();
			}	
		}
		
		private function handleYouTubeSeek(data:Object):void {
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player);
			if (player) {
				player.seekRequested(data.seek_to);
			}
		}			
		
		private function handleYouTubePlayerAdded(data:Object):void {
			if (data.room != currentRoom.id) { return; }
			var player:YouTubePlayerDefinition = YouTubePlayerDefinition.fromData(data.player);
			player.roomGuid = data.room;
			currentRoom.addYoutubePlayer(player);
		}
		
		private function handleYouTubePlayerMoved(data:Object):void {
			if (data.room != currentRoom.id) { return; }
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player.guid);
			if (player) {
				player.x = data.player.x;
				player.y = data.player.y;
				player.setSize(data.player.width, data.player.height);
			}
		}
		
		private function handleYouTubePlayerDataUpdated(data:Object):void {
			if (data.room != currentRoom.id) { return; }
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player.guid);
			player.data.updateData(data.player.data);
		}
		
		private function handleYouTubePlayerRemoved(data:Object):void {
			if (data.room != currentRoom.id) { return; }
			currentRoom.removeYoutubePlayer(data.guid);
		}
		
		private function handleYouTubeLoad(data:Object):void {
			if (data.room != currentRoom.id) { return; }
			var player:YouTubePlayerDefinition = currentRoom.getYoutubePlayerByGuid(data.player);
			
			// Load implies lock..
			var interactivityUser:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				var user:UserListEntry = new UserListEntry();
				user.username = interactivityUser.name;
				user.userGuid = interactivityUser.id;
				player.lockPlayerRequested(user, data.duration);
			}
			
			if (player && data.video_id) {
				player.loadVideoRequested(data.video_id, data.title, data.auto_play);
			}
		}
		
		private function handleInvitationToJoinFriend(data:Object):void {
			if (data.room_guid === currentRoom.id) { return; }
			Alert.show(data.user.username + " has invited you to come to \"" + data.room_name + "\" at " + data.world_name + ".  Would you like to teleport to " + data.user.username + "'s current location?",
				"Invitation from " + data.user.username,
				Alert.YES | Alert.NO | Alert.NONMODAL,
				null,
				function(event:CloseEvent):void {
					if (event.detail == Alert.YES) {
						gotoRoom(data.room_guid);
					}
				},
				null,
				Alert.YES
			);
		}
		
		private function handleRequestPermissionToJoin(data:Object):void {
			var friend:FriendsListEntry = new FriendsListEntry();
			friend.username = data.user.username;
			friend.guid = data.user.guid;
			
			var token:String = data.invitation_token;
			
			Alert.show(data.user.username + " has requested permission to join you.  Would you like " + data.user.username + " to be teleported to your current location?",
						"Request from " + data.user.username,
						Alert.YES | Alert.NO | Alert.NONMODAL,
						null,
						function(event:CloseEvent):void {
							if (event.detail == Alert.YES) {
								friend.grantPermissionToJoin(token);
							}
						},
						null,
						Alert.YES
			);
		}
		
		private function handlePermissionToJoinGranted(data:Object):void {
			var friendsList:FriendsList = FriendsList.getInstance();
			if (friendsList.invitationTokenIsValid(data.invitation_token)) {
				friendsList.consumeInvitationToken(data.invitation_token);
				var notification:VisualNotification = new VisualNotification(
					"Your request to join " + data.user.username + " was granted.  You are being teleported to their current location.",
					"Request Granted"
				);
				notification.show();
				gotoRoom(data.room_guid);
			}
		}
		
		private function handleFriendRemoved(data:Object):void {
			if (data.show_notification) {
				var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_REMOVED);
				notification.friendsListEntry = new FriendsListEntry();
				notification.friendsListEntry.guid = data.user.guid;
				notification.friendsListEntry.username = data.user.username;
				NotificationCenter.postNotification(notification);
			}
			friendsList.removeFriendFromListByGuid(data.user.guid);
		}
		
		private function handleFriendAdded(data:Object):void {
			var notification:FriendsNotification = new FriendsNotification(FriendsNotification.FRIEND_ADDED);
			notification.friendsListEntry = new FriendsListEntry();
			notification.friendsListEntry.username = data.user.username;
			if (data.facebook_friend) {
				notification.friendsListEntry.friendType = FriendsListEntry.TYPE_FACEBOOK;
			}
			else {
				notification.friendsListEntry.friendType = FriendsListEntry.TYPE_WORLIZE;
			}
			NotificationCenter.postNotification(notification);
		}
		
		private function handleFriendRequestAccepted(data:Object):void {
			var friend:FriendsListEntry = FriendsListEntry.fromData(data.user);
			friendsList.friendsForFriendsList.addItem(friend);
			friendsList.updateHeadingCounts();
		}
		
		private function handleNewFriendRequest(data:Object):void {
			var notification:VisualNotification = new VisualNotification(
				"You have received a friend request from " + data.user.username +".  " +
				"View your friends list to confirm your new friendship.",
				"Friend Request"
			);
			notificationManager.showNotification(notification);
			var entry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(data.user);
			friendsList.friendsForFriendsList.addItem(entry);
			friendsList.updateHeadingCounts();
		}
		
		private function handleNewObject(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.addObject(data.object.guid, data.object.x, data.object.y, data.object.fullsize_url);
			}
		}
		
		private function handleObjectMoved(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.moveObject(data.object.guid, data.object.x, data.object.y);
			}
		}
		
		private function handleObjectUpdated(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.updateObject(data.object.guid, data.object.dest);
			}
		}
		
		private function handleObjectRemoved(data:Object):void {
			if (data.room == currentRoom.id && data.guid) {
				currentRoom.removeObject(data.guid);
			}
		}
		
		private function handleGotoRoomMessage(data:Object):void {
			logger.debug("Received goto_room message from server, directing to room guid " + (data as String));
			gotoRoom(data as String);
		}
		
		private function handleRoomRedirect(data:Object):void {
			logger.info("Room Redirect for room " + data.room);
			expectingDisconnect = true
			actuallyGotoRoom(data.room as String);
		}
		
		private function handleNaked(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.simpleAvatar = null;
				user.videoAvatarStreamName = null;
			}
		}
		
		private function handleSetSimpleAvatar(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.videoAvatarStreamName = null;
				user.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(data.avatar.guid);
			}
		}
		
		private function handleSetVideoAvatar(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.simpleAvatar = null;
				if (user.isSelf) {
					user.videoAvatarStreamName = '_local';
				}
				else {
					user.videoAvatarStreamName = data.user;					
				}
			}
		}
		
		private function handlePing(data:Object):void {
			roomConnection.send({
				msg: "pong"
			});
		}
		
		private function handleHotspotDestUpdated(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				hotspot.dest = data.dest;
			}
		}
		
		private function handleHotspotRemoved(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				var authorModeState:AuthorModeState = AuthorModeState.getInstance();
				if (authorModeState.selectedItem === hotspot) {
					authorModeState.selectedItem = null;
				}
				
				var index:int = currentRoom.hotSpots.getItemIndex(hotspot);
				if (index != -1) {
					currentRoom.hotSpots.removeItemAt(index);
				}
				
				index = currentRoom.hotSpotsAboveNothing.getItemIndex(hotspot);
				if (index != -1) {
					currentRoom.hotSpotsAboveNothing.removeItemAt(index);
				}
				
				delete currentRoom.hotSpotsById[hotspot.id];
				delete currentRoom.hotSpotsByGuid[hotspot.guid];
			}
		}
		
		private function handleHotspotMoved(data:Object):void {
			var hotspot:Hotspot = currentRoom.hotSpotsByGuid[data.guid];
			if (hotspot) {
				hotspot.moveTo(data.x, data.y, data.points);
			}
		}
		
		private function handleNewHotspot(data:Object):void {
			var hotspot:Hotspot = Hotspot.fromData(data)
			currentRoom.hotSpots.addItem(hotspot);
			currentRoom.hotSpotsAboveNothing.addItem(hotspot);
			currentRoom.hotSpotsByGuid[hotspot.guid] = hotspot;
			currentRoom.hotSpotsById[hotspot.id] = hotspot;
		}
		
		private function handleRoomDefinition(data:Object):void {
			logger.info("Got room definition for room " + data.guid + ".");
			
			var room:RoomDefinition = RoomDefinition.fromData(data);
			currentRoom.id = room.guid;
			currentRoom.name = room.name;
			currentRoom.backgroundFile = room.backgroundImageURL;
			
			if (shouldInsertHistory) {
				roomHistoryManager.addItem(currentRoom.id, currentRoom.name, currentWorld.name);
			}
			
			// Hotspots:
			currentRoom.hotSpotsAboveNothing.removeAll();
			currentRoom.hotSpots.removeAll();
			currentRoom.hotSpotsByGuid = {};
			currentRoom.hotSpotsById = {};
			
			for each (var hotspot:Hotspot in room.hotspots) {
				currentRoom.hotSpots.addItem(hotspot);
				currentRoom.hotSpotsAboveNothing.addItem(hotspot);
				currentRoom.hotSpotsById[hotspot.id] = hotspot;
				currentRoom.hotSpotsByGuid[hotspot.guid] = hotspot;
			}
			
			// In-World Objects
			currentRoom.resetInWorldObjects();
			for each (var objectData:Object in room.objects) {
				currentRoom.addObject(objectData.guid, objectData.x, objectData.y, objectData.fullsize_url, objectData.dest);
			}
			
			// YouTube Players
			currentRoom.resetYoutubePlayers();
			for each (var youtubePlayerDefinition:YouTubePlayerDefinition in room.youtubePlayers) {
				currentRoom.addYoutubePlayer(youtubePlayerDefinition);
			}
		}
		
		public function setCyborg(cyborgScript:String):void {
			cyborgHotspot = new Hotspot();
			cyborgHotspot.scriptString = cyborgScript;
			cyborgHotspot.loadScripts();
		}
		
		public function gotoURL(url:String):void {
			var event:InteractivityEvent = new InteractivityEvent('gotoURL');
			event.url = url;
			dispatchEvent(event);
		}
		
		private function resetState():void {
			iptInteractivityController.clearAlarms();
			needToRunSignonHandlers = true;
			currentRoom.name = "";
			currentRoom.backgroundFile = null;
			currentRoom.selectedUser = null;
			currentRoom.removeAllUsers();
			currentRoom.hotSpots.removeAll();
			currentRoom.hotSpotsAboveAvatars.removeAll();
			currentRoom.hotSpotsAboveEverything.removeAll();
			currentRoom.hotSpotsAboveNametags.removeAll();
			currentRoom.hotSpotsAboveNothing.removeAll();
			currentRoom.hotSpotsByGuid = {};
			currentRoom.hotSpotsById = {};
			currentRoom.resetYoutubePlayers();
			currentRoom.drawBackCommands.removeAll();
			currentRoom.drawFrontCommands.removeAll();
			currentRoom.drawLayerHistory = new Vector.<uint>();
			currentRoom.inWorldObjects.removeAll();
			currentRoom.inWorldObjectsByGuid = {};
			currentRoom.showAvatars = true;
		}
		
		// ***************************************************************
		// Begin public functions for user interaction
		// ***************************************************************
		
		public function connect():void {
			if (roomConnectionState === WorlizeConnectionState.CONNECTING) {
				cancelRoomConnection();
			}
			
			InteractivityClient.loaderContext.checkPolicyFile = true;
			
			if (presenceConnection === null) {
				initPresenceConnection();
			}
			
			if (roomConnection) {
				roomConnection.removeEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
				roomConnection.removeEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
				roomConnection.removeEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleRoomConnectionFail);
				roomConnection.removeEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
			}
			
			roomConnectionState = WorlizeConnectionState.CONNECTING;
			roomConnection = new RoomConnection();
			
			roomConnection.addEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
			roomConnection.addEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
			roomConnection.addEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleRoomConnectionFail);
			roomConnection.addEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
			
			roomConnection.connect();
		}
		
		public function cancelRoomConnection():void {
			if (roomConnection) {
				roomConnection.removeEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
				roomConnection.removeEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
				roomConnection.removeEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleRoomConnectionFail);
				roomConnection.removeEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
				roomConnection.disconnect();
				roomConnection = null;
				roomConnectionState = WorlizeConnectionState.CLOSED;
			}
		}
		
		public function disconnect():void {
			if (roomConnection) {
				expectingDisconnect = true;
				roomConnection.disconnect();				
			}
			resetState();
		}
		
		public function youTubeLoad(playerGuid:String, videoId:String, duration:int, title:String, autoPlay:Boolean = true):void {
			roomConnection.send({
				msg: "youtube_load",
				data: {
					player: playerGuid,
					video_id: videoId,
					auto_play: autoPlay,
					duration: duration,
					title: title
				}
			});
		}
		
		public function youTubeStop(playerGuid:String):void {
			roomConnection.send({
				msg: "youtube_stop",
				data: {
					player: playerGuid
				}
			});
		}
		
		public function youTubePause(playerGuid:String):void {
			roomConnection.send({
				msg: "youtube_pause",
				data: {
					player: playerGuid
				}
			});
		}
		
		public function youTubeSeek(playerGuid:String, seekTo:int):void {
			roomConnection.send({
				msg: "youtube_seek",
				data: {
					player: playerGuid,
					seek_to: seekTo
				}
			});
		}
		
		public function youTubePlay(playerGuid:String):void {
			roomConnection.send({
				msg: "youtube_play",
				data: {
					player: playerGuid
				}
			});
		}
		
		public function roomChat(message:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}
//			trace("Saying: " + message);

			roomConnection.send({
				msg: "say",
				data: message
			});
		}
		
		public function privateMessage(message:String, targetUserGuid:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}
			
			roomConnection.send({
				msg: "whisper",
				data: {
					to_user: targetUserGuid,
					text: message
				}
			});
		}
		
		public function say(message:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}
			
			if (handleClientCommand(message)) { return; }
			
			if (message.charAt(0) == "/") {
				// Run iptscrae
				iptInteractivityController.executeScript(message.substr(1));
				return;
			}
			
			var selectedUserId:String = currentRoom.selectedUser ?
				currentRoom.selectedUser.id : null;
			
			var chatRecord:ChatRecord = new ChatRecord(
				ChatRecord.OUTCHAT,
				currentUser.id,
				selectedUserId,
				message,
				currentRoom.selectedUser ? true : false
			);
			chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_OUTCHAT);
			chatQueue.push(chatRecord);
			processChatQueue();
		}
		
		public function globalMessage(message:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}
			
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			roomConnection.send({
				msg: "global_msg",
				data: message
			});
		}
		
		public function roomMessage(message:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			roomConnection.send({
				msg: "room_msg",
				data: message
			});
		}
		
		public function superUserMessage(message:String):void {
			if (!roomConnected || message == null || message.length == 0) {
				return;
			}

			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			roomConnection.send({
				msg: "susr_msg",
				data: message
			});
		}
		
		private function handleClientCommand(message:String):Boolean {
			var clientCommandMatch:Array = message.match(/^~(\w+) (.*)$/);
			if (clientCommandMatch && clientCommandMatch.length > 0) {
				var command:String = clientCommandMatch[1];
				var argument:String = clientCommandMatch[2];
				switch (command) {
					default:
						logger.info("Unrecognized command: " + command + " argument " + argument);
				}
				return true;
			}
			else {
				return false;
			}
		}
		
		public function naked():void {
			currentUser.simpleAvatar = null;
			currentUser.videoAvatarStreamName = null;
			webcamBroadcastManager.stopBroadcast();
			roomConnection.send({
				msg: "naked"
			});
		}
		
		public function setSimpleAvatar(guid:String):void {
			currentUser.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(guid);
			webcamBroadcastManager.stopBroadcast();
			currentUser.videoAvatarStreamName = null;
			roomConnection.send({
				msg: "set_simple_avatar",
				data: guid
			});
		}
		
		public function setVideoAvatar():void {
			webcamBroadcastManager.netConnectionManager = netConnectionManager;
			webcamBroadcastManager.broadcastCamera(currentUser.id);
		}
		
		private function handleCameraBroadcastStart(event:WebcamBroadcastEvent):void {
			roomConnection.send({
				msg: 'set_video_avatar'
			});
		}
		
		private function handleCameraPermissionRevoked(event:WebcamBroadcastEvent):void {
			if (webcamBroadcastManager.broadcasting) {
				naked();
			}
		}
		
		public function move(x:int, y:int):void {
			if (!roomConnected || !currentUser) {
				return;
			}
			
			x = Math.max(x, 22);
			x = Math.min(x, currentRoom.roomView.backgroundImage.width - 22);
			
			y = Math.max(y, 22);
			y = Math.min(y, currentRoom.roomView.backgroundImage.height - 22);
			
			roomConnection.send({
				msg: "move",
				data: [x,y]
			});
			
			currentUser.x = x;
			currentUser.y = y;
		}
		
		public function setFace(face:int):void {
			if (!roomConnected || currentUser.face == face) {
				return;
			}
			
			if (face < 0) { face = 12; }
			if (face > 12) { face = 0; }
			
			currentUser.face = face;
			
			roomConnection.send({
				msg: "set_face",
				data: face
			});
		}
		
		public function setColor(color:int):void {
			if (!roomConnected || currentUser.color == color) {
				return;
			}
			
			if (color > 15) { color = 15; }
			if (color < 0) { color = 0; }
			
			currentUser.color = color;
			
			roomConnection.send({
				msg: "set_color",
				data: color
			});
			
			return;
		}
		
		public function createNewRoom(roomName:String = null):void {
			var newRoomOptions:Object = {};
			if (roomName) {
				newRoomOptions['room_name'] = roomName;
			}
			var client:WorlizeServiceClient = new WorlizeServiceClient();
			client.addEventListener(WorlizeResultEvent.RESULT, function(event:WorlizeResultEvent):void {
				if (event.resultJSON.success) {
					var notification:RoomChangeNotification = new RoomChangeNotification(RoomChangeNotification.ROOM_ADDED);
					NotificationCenter.postNotification(notification);
					gotoRoom(event.resultJSON.data.room_guid);
				}
				else {
					Alert.show("There was an error while trying to create the new area.", "Error");
				}
			});
			client.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				Alert.show("There was an error while trying to create the new area.", "Error");
			});
			client.send("/worlds/" + currentWorld.guid + "/rooms.json", HTTPMethod.POST, newRoomOptions);
		}
		
		private var leaveEventHandlers:Vector.<IptTokenList>;
		private var requestedRoomId:String = null;
		private var shouldInsertHistory:Boolean = true;

		public function gotoRoom(roomId:String, insertHistory:Boolean = true):void {
			if (currentRoom.id == roomId) {
				return;
			}

			shouldInsertHistory = insertHistory;
			needToRunSignonHandlers = false;
			
			requestedRoomId = roomId;
			
			leaveEventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_LEAVE);
			if (leaveEventHandlers) {
				for each (var handler:IptTokenList in leaveEventHandlers) {
					handler.addEventListener(IptEngineEvent.FINISH, handleLeaveEventHandlersFinish);
				}
				iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_LEAVE);
			}
			else {
				actuallyGotoRoom(roomId);
			}
		}
		
		private function handleLeaveEventHandlersFinish(event:IptEngineEvent):void {
			if (leaveEventHandlers == null) {
				actuallyGotoRoom(requestedRoomId);
			}
			
			// Make sure each ON LEAVE handler has finished before actually
			// leaving the room.
			var index:int = leaveEventHandlers.indexOf(IptTokenList(event.target));
			if (index != -1) {
				leaveEventHandlers.splice(index, 1);
			}
			if (leaveEventHandlers.length < 1) {
				actuallyGotoRoom(requestedRoomId);
				leaveEventHandlers = null;
				requestedRoomId = null;
			}
		}
		
		private function actuallyGotoRoom(roomId:String):void {
			logger.info("Actually going to room " + roomId);

			var gotoRoomCommand:GotoRoomCommand = new GotoRoomCommand();
			gotoRoomCommand.addEventListener(GotoRoomResultEvent.GOTO_ROOM_RESULT, function(event:GotoRoomResultEvent):void {
				worlizeConfig.interactivitySession = event.interactivitySession;
				
				if (currentWorld.guid != worlizeConfig.interactivitySession.worldGuid) {
					currentWorld.load(worlizeConfig.interactivitySession.worldGuid);
				} 
				
				if (roomConnection && roomConnection.connected) {
					expectingDisconnect = true;
					var disconnectHandler:Function = function(event:WorlizeCommEvent):void {
						RoomConnection(event.target).removeEventListener(WorlizeCommEvent.DISCONNECTED, disconnectHandler);
						resetState();
						connect();
					};
					roomConnection.addEventListener(WorlizeCommEvent.DISCONNECTED, disconnectHandler);
					roomConnection.disconnect();
				}
				else {
					resetState();
					connect();
				}
			});
			gotoRoomCommand.addEventListener(FaultEvent.FAULT, function(event:FaultEvent):void {
				currentRoom.logMessage("Unable to go to the requested room: it does not exist.");
			});
			gotoRoomCommand.execute(roomId);
		}
		
		public function reconnectToRoomServer():void {
			if (worlizeConfig.interactivitySession && worlizeConfig.interactivitySession.roomGuid) {
				actuallyGotoRoom(worlizeConfig.interactivitySession.roomGuid);
			}
		}
		
		public function lockDoor(roomId:String, spotId:int):void {
			roomConnection.send({
				msg: 'lock_door',
				data: {
					door_id: spotId
				}
			});
		}
		
		public function unlockDoor(roomGuid:String, spotId:int):void {
			roomConnection.send({
				msg: 'unlock_door',
				data: {
					roomGuid: roomGuid,
					spotId: spotId
				}
			});
		}
		
		[Bindable(event="currentUserChanged")]
		public function get currentUser():InteractivityUser {
			return currentRoom.getUserById(id);
		}
		
		public function updateUserProps():void {
			// tell server what props the user is wearing...
		}
		
		
		
		// ***************************************************************
		// Begin private functions to messages from the server
		// ***************************************************************
		
		private function handleUserNew(data:Object):void {
			var user:InteractivityUser = new InteractivityUser();
			user.isSelf = Boolean(data.guid == id);
			user.id = data.guid;
			user.x = data.position[0];
			user.y = data.position[1];
			user.name = data.userName;
			user.face = data.face;
			user.color = data.color;
			
			if (data.avatar) {
				if (data.avatar.type == "simple") {
					user.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(data.avatar.guid);
				}
				else if (data.avatar.type === "video") {
					user.videoAvatarStreamName = user.id;
				}
			}
			
			currentRoom.addUser(user);
			
			logger.info("User " + user.name + " entered.");
			
			if (user.id == id) {
				// Self entered
				// Signon handlers
				setTimeout(function():void {
					if (needToRunSignonHandlers) {
						
						iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_SIGNON);
						needToRunSignonHandlers = false;
					}
					
					// Enter handlers
					iptInteractivityController.triggerHotspotEvents(IptEventHandler.TYPE_ENTER);
				}, 20);
			}
			else if (currentRoom.selectedUser && user.id == currentRoom.selectedUser.id) {
				//if user was selected in user list then entered room
				currentRoom.selectedUser = user;
			}
		}

		/*
			Iptscrae event handlers have to process chat one piece at a time.
			Since iptscrae is run asynchronously, we have to wait for all event
			handlers for one chat event to complete before we process the next
			one.
		*/
		private function processChatQueue():void {
			if (chatQueue.length > 0) {
				if (currentChatItem) {
					// Bail if the current item isn't finished yet.
					return;
				}
				var currentItem:ChatRecord = chatQueue.shift();
				currentChatItem = currentItem;
				
				// These are global variables that need to persist even after
				// the last chat message has been processed
				whochat = currentItem.whochat;
				chatstr = currentItem.chatstr;
				
				if (currentItem.eventHandlers) {
					for each (var handler:IptTokenList in currentItem.eventHandlers) {
						handler.addEventListener(IptEngineEvent.FINISH, handleChatEventFinish);
					}
					iptInteractivityController.triggerHotspotEvents(
						(currentItem.direction == ChatRecord.INCHAT) ?
							IptEventHandler.TYPE_INCHAT :
							IptEventHandler.TYPE_OUTCHAT
					);
				}
				else {
					// If there aren't any event handlers, skip directly to
					// processing the chat.
					handleChatEventFinish();
				}
			}
		}
		
		private function handleChatEventFinish(event:IptEngineEvent=null):void {
			if (currentChatItem) {
				
				if (event) {
					// If an event handler has fired, pull it from the
					// currentChatItem's list of events, and continue
					// processing the chat only after all event handlers
					// have executed.
					IptTokenList(event.target).removeEventListener(IptEngineEvent.FINISH, handleChatEventFinish);
					var listIndex:int = currentChatItem.eventHandlers.indexOf(IptTokenList(event.target));
					if (listIndex != -1) {
						currentChatItem.eventHandlers.splice(listIndex, 1);
					}
					else {
						return;
					}
					if (currentChatItem.eventHandlers.length > 0) {
						// If there are more event handlers still to run,
						// bail and wait for them to finish.
						return;
					}
				}
				else if (currentChatItem.eventHandlers != null) {
					throw new Error("There are event handlers to run for this " +
                                    "chat record, but processing was attempted " +
									"without an event triggering it!");
				}
				
				currentChatItem.chatstr = chatstr;
				
				if (currentChatItem.direction == ChatRecord.INCHAT) {

					if (currentChatItem.whisper) {
						currentRoom.whisper(currentChatItem.whochat, currentChatItem.chatstr, currentChatItem.originalChatstr);
					}
					else {
						currentRoom.chat(currentChatItem.whochat, currentChatItem.chatstr, currentChatItem.originalChatstr);
					}
					
				}
				else if (currentChatItem.direction == ChatRecord.OUTCHAT) {
					
					if (currentChatItem.whisper) {
						privateMessage(currentChatItem.chatstr, currentChatItem.whotarget);
					}
					else {
						roomChat(currentChatItem.chatstr);
					}
					
				}
				
				currentChatItem = null;
			}
			
			// Keep processing the queue until it's empty.
			processChatQueue();
		}
		
		private function handleReceiveWhisper(data:Object):void {
			var message:String = data.text;
			var whochat:String = data.user;
			if (message.length > 0) {
				var chatRecord:ChatRecord = new ChatRecord(
					ChatRecord.INCHAT,
					whochat,
					null,
					message,
					true
				);
				chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_INCHAT);
				chatQueue.push(chatRecord);
				processChatQueue();
			}
		}
		
		private function handleReceiveTalk(data:Object):void {
			var message:String = data.text;
			var whochat:String = data.user;
			var chatRecord:ChatRecord = new ChatRecord(
				ChatRecord.INCHAT,
				whochat,
				null,
				message
			);
			chatRecord.eventHandlers = iptInteractivityController.getHotspotEvents(IptEventHandler.TYPE_INCHAT);
			chatQueue.push(chatRecord);
			processChatQueue();
		}
		
		private function handleGlobalMessage(data:Object):void {
			currentRoom.roomMessage(String(data));
		}
		
		private function handleMove(data:Object):void {
			var user:String = data.user;
			var y:int = data.position[1];
			var x:int = data.position[0];
			currentRoom.moveUser(user, x, y);
		}
		
		private function handleUserFace(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			user.face = data.face;
		}
		
		private function handleUserColor(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			user.color = data.color;
		}
				
		private function handleUserLeaving(data:Object):void {
			var userId:String = String(data);
			if (currentRoom.getUserById(userId) != null) {
				currentRoom.removeUserById(userId);
			}

			//if user left room and ESP is active when they sign off
			if (currentRoom.selectedUser && currentRoom.selectedUser.id == userId)
			{
				currentRoom.selectedUser = null;
			}
		}
	}
}