package com.worlize.interactivity.rpc
{
	import com.adobe.net.URI;
	import com.worlize.command.GotoRoomCommand;
	import com.worlize.components.visualnotification.VisualNotification;
	import com.worlize.components.visualnotification.VisualNotificationManager;
	import com.worlize.control.VirtualCurrencyProducts;
	import com.worlize.event.AuthorModeNotification;
	import com.worlize.event.GotoRoomResultEvent;
	import com.worlize.event.NotificationCenter;
	import com.worlize.interactivity.api.APIController;
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
	import com.worlize.interactivity.model.StateHistoryEntry;
	import com.worlize.interactivity.model.WebcamBroadcastManager;
	import com.worlize.interactivity.record.ChatRecord;
	import com.worlize.interactivity.rpc.messages.AppBroadcastMessage;
	import com.worlize.interactivity.rpc.messages.StateHistoryClearMessage;
	import com.worlize.interactivity.rpc.messages.StateHistoryDumpMessage;
	import com.worlize.interactivity.rpc.messages.StateHistoryPushMessage;
	import com.worlize.interactivity.rpc.messages.StateHistoryShiftMessage;
	import com.worlize.interactivity.view.SoundPlayer;
	import com.worlize.model.AvatarInstance;
	import com.worlize.model.BackgroundImageInstance;
	import com.worlize.model.CurrentUser;
	import com.worlize.model.InWorldObjectInstance;
	import com.worlize.model.PreferencesManager;
	import com.worlize.model.PublicWorldsList;
	import com.worlize.model.RoomDefinition;
	import com.worlize.model.RoomList;
	import com.worlize.model.RoomListEntry;
	import com.worlize.model.SimpleAvatar;
	import com.worlize.model.SimpleAvatarStore;
	import com.worlize.model.UserList;
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
	import com.worlize.model.locker.Slots;
	import com.worlize.notification.AvatarNotification;
	import com.worlize.notification.BackgroundImageNotification;
	import com.worlize.notification.ConnectionNotification;
	import com.worlize.notification.FinancialNotification;
	import com.worlize.notification.FriendsNotification;
	import com.worlize.notification.InWorldObjectNotification;
	import com.worlize.notification.RoomChangeNotification;
	import com.worlize.rpc.ConnectionManager;
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
		
		[Bindable]
		public var preferencesManager:PreferencesManager = PreferencesManager.getInstance();
		
		[Bindable]
		public var currentWorld:WorldDefinition = new WorldDefinition();
		
		[Bindable]
		public var currentRoom:CurrentRoom = new CurrentRoom();
		
		[Bindable]
		public var webcamBroadcastManager:WebcamBroadcastManager = new WebcamBroadcastManager();
		
		public var roomById:Object = {};
		
		public var chatstr:String = "";
		public var whochat:String = null;
		public var needToRunSignonHandlers:Boolean = true; 
		
		private var chatQueue:Vector.<ChatRecord> = new Vector.<ChatRecord>;
		private var currentChatItem:ChatRecord;
		
		public var cyborgHotspot:Hotspot = new Hotspot();
		
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
		
		[Bindable]
		public var connection:ConnectionManager;
		
		public var apiController:APIController;
		
		private var receivingInitialRoomOccupants:Boolean = false;
		
		public var expectingDisconnect:Boolean = false;
		
		// Incoming Message Handlers
		private var incomingMessageHandlers:Object = {
			"avatar_instance_added": handleAvatarInstanceAdded,
			"avatar_instance_deleted": handleAvatarInstanceDeleted,
			"background_instance_added": handleBackgroundInstanceAdded,
			"background_instance_updated": handleBackgroundInstanceUpdated,
			"balance_updated": handleBalanceUpdated,
			"disconnect": handleDisconnectMessage,
			"friend_added": handleFriendAdded,
			"friend_removed": handleFriendRemoved,
			"friend_request_accepted": handleFriendRequestAccepted,
			"gift_received": handleGiftReceived,
			"global_msg": handleGlobalMessage,
			"goto_room": handleGotoRoomMessage,
			"hotspot_moved": handleHotspotMoved,
			"hotspot_removed": handleHotspotRemoved,
			"hotspot_dest_updated": handleHotspotDestUpdated,
			"in_world_object_instance_added": handleInWorldObjectInstanceAdded,
			"invitation_to_join_friend": handleInvitationToJoinFriend,
			"logged_out": handleLoggedOut,
			"move": handleMove,
			"naked": handleNaked,
			"new_friend_request": handleNewFriendRequest,
			"new_hotspot": handleNewHotspot,
			"new_object": handleNewObject,
			"object_moved": handleObjectMoved,
			"object_removed": handleObjectRemoved,
			"object_updated": handleObjectUpdated, // dest changed
			"payment_completed": handlePaymentCompleted,
			"ping": handlePing,
			"presence_status_change": handlePresenceStatusChange,
			"request_permission_to_join": handleRequestPermissionToJoin,
			"room_definition": handleRoomDefinition,
			"room_entry_denied": handleRoomEntryDenied,
			"room_entry_granted": handleRoomEntryGranted,
			"room_msg": handleRoomMsg,
			"room_population_update": handleRoomPopulationUpdate,
			"room_redirect": handleRoomRedirect,
			"say": handleReceiveTalk,
			"set_color": handleUserColor,
			"set_face": handleUserFace,
			"set_simple_avatar": handleSetSimpleAvatar,
			"set_video_avatar": handleSetVideoAvatar,
			"set_video_server": handleSetVideoServer,
			"slots_updated": handleSlotsUpdated,
			"update_room_property": handleUpdateRoomProperty,
			"user_enter": handleUserNew,
			"user_leave": handleUserLeaving,
			"whisper": handleReceiveWhisper,
			"youtube_load": handleYouTubeLoad,
			"youtube_pause": handleYouTubePause,
			"youtube_play": handleYouTubePlay,
			"youtube_player_added": handleYouTubePlayerAdded,
			"youtube_player_moved": handleYouTubePlayerMoved,
			"youtube_player_data_updated": handleYouTubePlayerDataUpdated,
			"youtube_player_removed": handleYouTubePlayerRemoved,
			"youtube_seek": handleYouTubeSeek,
			"youtube_stop": handleYouTubeStop
		};
		
		private var incomingBinaryMessageHandlers:Object = {
			0x42435354: handleAppBroadcastMessage,
			0x4C505348: handleStateHistoryPushMessage,
			0x4C534654: handleStateHistoryShiftMessage,
			0x4C434C52: handleStateHistoryClearMessage,
			0x4C444D50: handleStateHistoryDumpMessage
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
			
			apiController = new APIController(this);
			
			connection = new ConnectionManager();
			connection.addEventListener(WorlizeCommEvent.CONNECTED, handleConnected);
			connection.addEventListener(WorlizeCommEvent.DISCONNECTED, handleDisconnected);
			connection.addEventListener(WorlizeCommEvent.CONNECTION_FAIL, handleConnectionFail);
			connection.addEventListener(WorlizeCommEvent.MESSAGE, handleIncomingMessage);
			
			ChangeWatcher.watch(this, ['currentWorld', 'ownerGuid'], handleWorldOwnerChange);
		}
		
		[Bindable(event="connectedChange")]
		public function get connected():Boolean {
			return connection.connected;
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
		
		public function connect():void {
			InteractivityClient.loaderContext.checkPolicyFile = true;
			connection.connect();
		}
		
		public function disconnect():void {
			expectingDisconnect = true;
			connection.disconnect();
			resetState();
		}
		
		private function handleConnected(event:WorlizeCommEvent):void {
			logger.info("Server Connection Established.");
			var connectEvent:InteractivityEvent = new InteractivityEvent(InteractivityEvent.CONNECT_COMPLETE);
			dispatchEvent(connectEvent);
			var notification:ConnectionNotification = new ConnectionNotification(ConnectionNotification.CONNECTION_ESTABLISHED);
			NotificationCenter.postNotification(notification);
			dispatchEvent(new FlexEvent("connectedChange"));
			
			logger.info("Now that the connection is established, checking for promo dialogs to display.");
			ExternalInterface.call('checkForDialogs');
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
					connect();
				}
			);
		}
		
		private function handleDisconnected(event:WorlizeCommEvent):void {
			var notification:ConnectionNotification = new ConnectionNotification(ConnectionNotification.DISCONNECTED);
			NotificationCenter.postNotification(notification);

			if (expectingDisconnect) {
				// do nothing
				logger.info("Disconnected from room server, but was expecting disconnection.");
			}
			else {
				logger.error("Disconnected from server!");
				resetState();
				showDisconnectedMessage();
			}
			expectingDisconnect = false;
			dispatchEvent(new FlexEvent("connectedChange"));
		}
		
		private function handleConnectionFail(event:WorlizeCommEvent):void {

		}
		
		private function handleIncomingMessage(event:WorlizeCommEvent):void {
			if (event.binaryData) {
				routeIncomingBinaryMessage(event.binaryData);
			}
			else {
				routeIncomingMessage(event.message);
			}
		}
		
		private function routeIncomingMessage(message:Object):void {
			if (message && message.msg) {
				logger.debug("Incoming Message: " + message.msg);
				var data:Object = null;
				if (message['data']) {
					data = message.data;
				}
				var handlerFunction:Function = incomingMessageHandlers[message.msg];
				if (handlerFunction is Function) {
					handlerFunction(data);
				}
				else {
					logger.warn("Unhandled message: " + JSON.stringify(message));
				}
			}
		}
		
		private function routeIncomingBinaryMessage(data:ByteArray):void {
			if (data.length < 4) {
				logger.error("Incoming binary message missing 4-byte message identifier.");
				return;
			}
			data.position = 0;
			var messageId:uint = data.readUnsignedInt();
			var handlerFunction:Function = incomingBinaryMessageHandlers[messageId];
			if (handlerFunction is Function) {
				data.position = 0;
				handlerFunction(data);
			}
			else {
				logger.warn("Unhandled binary message ID: 0x" + messageId.toString(16));
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
		
		private function handleSlotsUpdated(data:Object):void {
			var slots:Slots = CurrentUser.getInstance().slots;
			if (typeof(data.avatar_slots) === 'number') {
				slots.avatarSlots = data.avatar_slots;
			}
			if (typeof(data.background_slots) === 'number') {
				slots.backgroundSlots = data.background_slots;
			}
			if (typeof(data.in_world_object_slots) === 'number') {
				slots.inWorldObjectSlots = data.in_world_object_slots;
			}
			if (typeof(data.prop_slots) === 'number') {
				slots.propSlots = data.prop_slots;
			}
		}
		
		private function handleDisconnectMessage(data:Object):void {
			logger.info("Server sent disconnect message.");
//			Alert.show(data.error_code + " - " + data.error_message, "Disconnect");
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
		
		private function handleBackgroundInstanceUpdated(data:Object):void {
			var notification:BackgroundImageNotification = new BackgroundImageNotification(BackgroundImageNotification.BACKGROUND_INSTANCE_UPDATED);
			notification.updatedBackgroundInstanceGuid = data.guid;
			notification.updatedBackgroundInstanceData = data;
			NotificationCenter.postNotification(notification);
		}
		
		private function handleGiftReceived(data:Object):void {
			var gift:Gift = Gift.fromData(data.gift);
			GiftsList.getInstance().addGift(gift);
			var message:String;
			var titleMessage:String;
			if (gift.sender) {
				message = "You've received a gift from " + gift.sender.username + "!  Click \"Gifts\" at the top of the screen to accept it!";
				titleMessage = "New gift from " + gift.sender.username + "!";
			}
			else {
				message = "You've received a gift!  Click \"Gifts\" at the top of the screen to accept it!";
				titleMessage = "New gift received!";
			}
			var notification:VisualNotification = new VisualNotification(message, "Gift Received!", titleMessage);
			notification.show();
			SoundPlayer.getInstance().playRequestReceivedSound();
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
			SoundPlayer.getInstance().playRequestReceivedSound();
			
			var notification:VisualNotification = new VisualNotification();
			notification.onlyWhenInactive = true;
			notification.title = "Invitation Received";
			notification.text = data.user.username + " invited you to come to \"" + data.room_name + "\" at " + data.world_name + ". " +
				                "Switch back to worlize to respond to their request.";
			notification.titleFlashText = data.user.username + " invited you to join them.";
			notification.show();
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
			SoundPlayer.getInstance().playRequestReceivedSound();
			
			var notification:VisualNotification = new VisualNotification();
			notification.onlyWhenInactive = true;
			notification.title = "Request to Visit";
			notification.text = data.user.username + " wants to join you. Switch back to Worlize to respond to their request.";
			notification.titleFlashText = data.user.username + " wants to join you.";
			notification.show();
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
			var notification:VisualNotification = new VisualNotification();
			notification.text =
				"You have received a friend request from " + data.user.username +".  " +
				"View your friends list to confirm your new friendship.";
			notification.title = "Friend Request";
			notification.titleFlashText = "New Friend Request from " + data.user.username + "!";
			notification.show();
			
			var entry:PendingFriendsListEntry = PendingFriendsListEntry.fromData(data.user);
			friendsList.friendsForFriendsList.addItem(entry);
			friendsList.updateHeadingCounts();
			SoundPlayer.getInstance().playRequestReceivedSound();
		}
		
		private function handleNewObject(data:Object):void {
			if (data.room == currentRoom.id && data.object) {
				currentRoom.addObject(data.object);
			}
		}
		
		
		// BEGIN Binary Message Handler Functions
		
		private function handleAppBroadcastMessage(data:ByteArray):void {
			var msg:AppBroadcastMessage = new AppBroadcastMessage();
			msg.deserialize(data);
			
			apiController.sendObjectMessageLocal(msg.fromAppInstanceGuid, msg.message, msg.toAppInstanceGuid, msg.fromUserGuid);
		}
		
		private function handleStateHistoryPushMessage(data:ByteArray):void {
			var msg:StateHistoryPushMessage = new StateHistoryPushMessage();
			msg.deserialize(data);
			
			var inWorldObjectInstance:InWorldObjectInstance = currentRoom.getInWorldObjectInstanceById(msg.appInstanceGuid);
			if (inWorldObjectInstance) {
				if (!inWorldObjectInstance.stateHistory) {
					inWorldObjectInstance.stateHistory = [];
				}
				var entry:StateHistoryEntry = new StateHistoryEntry();
				entry.userGuid = msg.userGuid;
				entry.data = msg.data;
				inWorldObjectInstance.stateHistory.push(entry);
			}
			
			apiController.receiveStateHistoryPush(msg.appInstanceGuid, msg.userGuid, msg.data);
		}
		
		private function handleStateHistoryShiftMessage(data:ByteArray):void {
			var msg:StateHistoryShiftMessage = new StateHistoryShiftMessage();
			msg.deserialize(data);
			
			var inWorldObjectInstance:InWorldObjectInstance = currentRoom.getInWorldObjectInstanceById(msg.appInstanceGuid);
			if (inWorldObjectInstance) {
				if (!inWorldObjectInstance.stateHistory) {
					inWorldObjectInstance.stateHistory = [];
				}
				if (inWorldObjectInstance.stateHistory.length > 0) {
					inWorldObjectInstance.stateHistory.shift();
				}
			}
			
			apiController.receiveStateHistoryShift(msg.appInstanceGuid, msg.userGuid);
		}
		
		private function handleStateHistoryClearMessage(data:ByteArray):void {
			var msg:StateHistoryClearMessage = new StateHistoryClearMessage();
			msg.deserialize(data);
			
			var inWorldObjectInstance:InWorldObjectInstance = currentRoom.getInWorldObjectInstanceById(msg.appInstanceGuid);
			if (inWorldObjectInstance) {
				inWorldObjectInstance.stateHistory = [];
			}
			
			apiController.receiveStateHistoryClear(msg.appInstanceGuid, msg.userGuid);
		}
		
		private function handleStateHistoryDumpMessage(data:ByteArray):void {
			var msg:StateHistoryDumpMessage = new StateHistoryDumpMessage();
			msg.deserialize(data);
			
			var inWorldObjectInstance:InWorldObjectInstance = currentRoom.getInWorldObjectInstanceById(msg.appInstanceGuid);
			if (inWorldObjectInstance) {
				inWorldObjectInstance.stateHistory = msg.stateEntries;
			}
		}
		
		// END Binary Message Handler Functions
		
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
				apiController.userAvatarChanged(user);
			}
		}
		
		private function handleSetSimpleAvatar(data:Object):void {
			var user:InteractivityUser = currentRoom.getUserById(data.user);
			if (user) {
				user.videoAvatarStreamName = null;
				user.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(data.avatar.guid);
				apiController.userAvatarChanged(user);
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
				apiController.userAvatarChanged(user);
			}
		}
		
		private function handlePing(data:Object):void {
			connection.send({
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
			currentRoom.ownerGuid = room.ownerGuid;
			currentRoom.backgroundFile = room.backgroundImageURL;
			currentRoom.selfUserId = id;
			
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
				currentRoom.addObject(objectData);
			}
			
			// YouTube Players
			currentRoom.resetYoutubePlayers();
			for each (var youtubePlayerDefinition:YouTubePlayerDefinition in room.youtubePlayers) {
				currentRoom.addYoutubePlayer(youtubePlayerDefinition);
			}
			
			// Update room properties, resetting to defaults for all values if
			// no value is supplied for a given property in the room definition.
			currentRoom.updateProperties(room.properties, true);
			
			// Now we're ready to receive user_enter messages for all the
			// existing room occupants.  We don't want to play a notification
			// sound for every single one of them so we set this flag to true
			// until we receive the user_enter message for ourself.
			receivingInitialRoomOccupants = true;
		}
		
		private function handleRoomEntryDenied(data:Object):void {
			currentRoom.localMessage(data.message);
		}

		// Entry into the requested room was granted so prepare for entry by
		// loading the correct world definition and updating the local room
		// list.
		private function handleRoomEntryGranted(data:Object):void {
			logger.info("Room entry granted!  Room Guid: " + data.roomGuid + " World Guid: " + data.worldGuid);
			resetState();
			
			// Make sure to refresh the information about the current world
			// when going to a new room.
			currentWorld.load(data.worldGuid);
			
			// Make sure to update the room count since we won't receive a
			// room_population_update message after we disconnect.
			for (var i:int=0; i < currentWorld.roomList.rooms.length; i ++) {
				var roomListEntry:RoomListEntry = currentWorld.roomList.rooms.getItemAt(i) as RoomListEntry;
				if (roomListEntry.guid === currentRoom.id) {
					roomListEntry.userCount --;
					break;
				}
			}
		}
		
		private function handleRoomMsg(data:Object):void {
			currentRoom.roomMessage(data.text);
		}
		
		private function handleUpdateRoomProperty(data:Object):void {
			currentRoom.updateProperty(data.name, data.value);
		}
		
		// Keep the user/room list in sync
		private function handleRoomPopulationUpdate(data:Object):void {
			var userList:UserList = currentWorld.userList;
			var roomList:RoomList = currentWorld.roomList;
			var userListEntry:UserListEntry;
			var roomListEntry:RoomListEntry;
			var i:int;
			
			for each (roomListEntry in roomList.rooms) {
				if (roomListEntry.guid === data.guid) {
					break;
				}
			}
			if (roomListEntry) {
				roomListEntry.userCount = data.userCount;
			}
			else {
				// apparently the room wasn't in the list.  Let's add it.
				roomListEntry = new RoomListEntry();
				roomListEntry.guid = data.guid;
				roomListEntry.name = data.name;
				roomListEntry.userCount = data.userCount;
				roomList.rooms.addItem(roomListEntry);
			}
			
			if (data.userAdded) {
				// If the user is already in the list, update their data.
				// Otherwise, add the user to the list.
				var foundUser:Boolean = false;
				for each (userListEntry in userList.users) {
					if (userListEntry.userGuid === data.userAdded.guid) {
						foundUser = true;
						userListEntry.roomGuid = data.guid;
						userListEntry.roomName = data.name;
					}
				}
				if (!foundUser) {
					userListEntry = new UserListEntry();
					userListEntry.username = data.userAdded.userName;
					userListEntry.userGuid = data.userAdded.guid;
					userListEntry.roomGuid = data.guid;
					userListEntry.roomName = data.name;
					userList.users.addItem(userListEntry);
				}
			}
			
			if (data.userRemoved) {
				// Find the user in the user list and remove them
				for (i=0; i < userList.users.length; i ++) {
					userListEntry = userList.users.getItemAt(i) as UserListEntry;
					if (userListEntry.userGuid === data.userRemoved.guid) {
						userList.users.removeItemAt(i);
						break;
					}
				}
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
		public function updateRoomProperty(propertyName:String, value:*):void {
			if (canAuthor) {
				connection.send({
					msg: "update_room_property",
					data: {
						name: propertyName,
						value: value
					}
				}, true);
			}
		}
		
		public function youTubeLoad(playerGuid:String, videoId:String, duration:int, title:String, autoPlay:Boolean = true):void {
			connection.send({
				msg: "youtube_load",
				data: {
					player: playerGuid,
					video_id: videoId,
					auto_play: autoPlay,
					duration: duration,
					title: title
				}
			}, true);
		}
		
		public function youTubeStop(playerGuid:String):void {
			connection.send({
				msg: "youtube_stop",
				data: {
					player: playerGuid
				}
			}, true);
		}
		
		public function youTubePause(playerGuid:String):void {
			connection.send({
				msg: "youtube_pause",
				data: {
					player: playerGuid
				}
			}, true);
		}
		
		public function youTubeSeek(playerGuid:String, seekTo:int):void {
			connection.send({
				msg: "youtube_seek",
				data: {
					player: playerGuid,
					seek_to: seekTo
				}
			}, true);
		}
		
		public function youTubePlay(playerGuid:String):void {
			connection.send({
				msg: "youtube_play",
				data: {
					player: playerGuid
				}
			}, true);
		}
		
		public function broadcastObjectMessage(fromAppInstanceGuid:String, message:ByteArray, toAppInstanceGuid:String=null, toUserGuid:String=null):void {
			var msg:AppBroadcastMessage = new AppBroadcastMessage();
			msg.fromAppInstanceGuid = fromAppInstanceGuid;
			msg.toAppInstanceGuid = toAppInstanceGuid;
			msg.message = message;
			msg.toUserGuid = toUserGuid;
			
			connection.send(msg);
		}
		
		public function stateHistoryPush(appInstanceGuid:String, data:ByteArray):void {
			var msg:StateHistoryPushMessage = new StateHistoryPushMessage();
			msg.appInstanceGuid = appInstanceGuid;
			msg.data = data;
			
			connection.send(msg);
		}
		
		public function stateHistoryShift(appInstanceGuid:String):void {
			var msg:StateHistoryShiftMessage = new StateHistoryShiftMessage();
			msg.appInstanceGuid = appInstanceGuid;
			
			connection.send(msg);
		}
		
		public function stateHistoryClear(appInstanceGuid:String):void {
			var msg:StateHistoryClearMessage = new StateHistoryClearMessage();
			msg.appInstanceGuid = appInstanceGuid;
			
			connection.send(msg);
		}
		
		public function roomChat(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
//			trace("Saying: " + message);

			connection.send({
				msg: "say",
				data: message
			}, true);
		}
		
		public function privateMessage(message:String, targetUserGuid:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			connection.send({
				msg: "whisper",
				data: {
					to_user: targetUserGuid,
					text: message
				}
			}, true);
		}
		
		public function say(message:String):void {
			if (!connected || message == null || message.length == 0) {
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
			if (!connected || message == null || message.length == 0) {
				return;
			}
			
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			connection.send({
				msg: "global_msg",
				data: message
			});
		}
		
		public function roomMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}
			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			connection.send({
				msg: "room_msg",
				data: message
			});
		}
		
		public function superUserMessage(message:String):void {
			if (!connected || message == null || message.length == 0) {
				return;
			}

			if (message.length > 254) {
				message = message.substr(0, 254);
			}
			
			connection.send({
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
			if (connected) {
				if (currentUser) {
					currentUser.simpleAvatar = null;
					currentUser.videoAvatarStreamName = null;
				}
				webcamBroadcastManager.stopBroadcast();
				connection.send({
					msg: "naked"
				});
				apiController.userAvatarChanged(currentUser);
			}
		}
		
		public function setSimpleAvatar(guid:String):void {
			currentUser.simpleAvatar = SimpleAvatarStore.getInstance().getAvatar(guid);
			webcamBroadcastManager.stopBroadcast();
			currentUser.videoAvatarStreamName = null;
			connection.send({
				msg: "set_simple_avatar",
				data: guid
			});
			apiController.userAvatarChanged(currentUser);
		}
		
		public function setVideoAvatar():void {
			webcamBroadcastManager.netConnectionManager = netConnectionManager;
			webcamBroadcastManager.broadcastCamera(currentUser.id);
		}
		
		private function handleCameraBroadcastStart(event:WebcamBroadcastEvent):void {
			connection.send({
				msg: 'set_video_avatar'
			});
			apiController.userAvatarChanged(currentUser);
		}
		
		private function handleCameraPermissionRevoked(event:WebcamBroadcastEvent):void {
			if (webcamBroadcastManager.broadcasting) {
				naked();
			}
		}
		
		public function move(x:int, y:int):void {
			if (!connected || !currentUser) {
				return;
			}
			
			x = Math.max(x, 22);
			x = Math.min(x, currentRoom.roomView.backgroundImage.width - 22);
			
			y = Math.max(y, 22);
			y = Math.min(y, currentRoom.roomView.backgroundImage.height - 22);
			
			connection.send({
				msg: "move",
				data: [x,y]
			});
			
			currentRoom.moveUser(currentUser.id, x, y);
		}
		
		public function setFace(face:int):void {
			if (!connected || currentUser.face == face) {
				return;
			}
			
			if (face < 0) { face = 12; }
			if (face > 12) { face = 0; }
			
			currentUser.face = face;
			
			connection.send({
				msg: "set_face",
				data: face
			});
			
			apiController.userFaceChanged(currentUser);
		}
		
		public function setColor(color:int):void {
			if (!connected || currentUser.color == color) {
				return;
			}
			
			if (color > 15) { color = 15; }
			if (color < 0) { color = 0; }
			
			currentUser.color = color;
			
			connection.send({
				msg: "set_color",
				data: color
			});
			
			apiController.userColorChanged(currentUser);
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
		
		private function actuallyGotoRoom(roomGuid:String):void {
			logger.info("Actually going to room " + roomGuid);
			connection.gotoRoom(roomGuid);
		}
		
		public function lockDoor(roomId:String, spotId:int):void {
			connection.send({
				msg: 'lock_door',
				data: {
					door_id: spotId
				}
			});
		}
		
		public function unlockDoor(roomGuid:String, spotId:int):void {
			connection.send({
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
			
			if (!receivingInitialRoomOccupants) {
				SoundPlayer.getInstance().playUserEnterSound();
				var notification:VisualNotification = new VisualNotification();
				notification.onlyWhenInactive = true;
				notification.onlyUseNative = true;
				notification.title = user.name + " entered the room.";
				notification.text = "";
				notification.titleFlashText = user.name + " entered the room.";
				notification.show();
			}
			
			if (user.id == id) {
				// Self entered
				
				// When we receive our own user_enter message, we know we're
				// done receiving the pre-existing room occupants.  We can now
				// set receivingInitialRoomOccupants to false so that any
				// additional entrants to the room will play the user entered
				// sound alert.
				receivingInitialRoomOccupants = false;
				
				
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
				
				apiController.processChat(currentChatItem);
				
				
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